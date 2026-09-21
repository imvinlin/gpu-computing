#include <cuda_runtime.h>
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <thread>
#include <vector>

// CUDA Checker 
inline void cuda_check(cudaError_t e){
  if (e != cudaSuccess) {
    std::fprintf(stderr, "CUDA: %s\n", cudaGetErrorString(e));
    std::exit(1);
  }
}
#define CUDA_CHECK(call) cuda_check(call)

// Sequential C Code 
void vecadd_cpu(const float* x, const float* y, float* z, int N) {
  for (int i = 0; i < N; i++) {
    z[i] = x[i] + y[i];
  }
}

bool verify(const float* got, const float* ref, int N, float tol) {
  for (int i = 0; i < N; i++) {
    if (std::fabs(got[i] - ref[i]) > tol) return false;
  }
  return true;
}

// CPU Threads 
void add_range(const float* x, const float* y, float* z, int begin, int end) {
  for (int i = begin; i < end; i++) z[i] = x[i] + y[i];
}

void vecadd_cpu_mt(const float* x, const float* y, float* z, int N, int T) {
  int chunk = (N + T - 1) / T;
  std::vector<std::thread> workers;
  for (int t = 0; t < T; t++) {
    int begin = t * chunk, end = std::min(begin + chunk, N);
    workers.emplace_back(add_range, x, y, z, begin, end);
  }
  for (auto& worker: workers) worker.join();
}

// GPU Code (Device)

__global__ void vecadd_kernel(const float* x, const float* y, float* z, int N) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i < N) 
    z[i] = x[i] + y[i];
}

// Timing
using Clock = std::chrono::high_resolution_clock;
double elapsed_ms(Clock::time_point start, Clock::time_point end) {
  return std::chrono::duration<double, std::milli>(end-start).count();
}

// Host Code 
int main(int argc, char** argv) {
  int N = (argc > 1) ? std::atoi(argv[1]) : 1000;
  if (N <= 0) { std::fprintf(stderr, "N must be > 0\n"); return 1; }

  size_t bytes = size_t(N) * sizeof(float);
  std::vector<float> x(N, 1.0f), y(N, 2.0f);
  std::vector<float> got(N), ref(N), got_mt(N);

  // CPU sequential
  auto t0 = Clock::now();
  vecadd_cpu(x.data(), y.data(), ref.data(),N);
  double cpu_seq_ms = elapsed_ms(t0, Clock::now());

  // CPU multithreaded
  int T = std::max(1u, std::thread::hardware_concurrency());
  t0 = Clock::now();
  vecadd_cpu_mt(x.data(), y.data(), got_mt.data(), N, T);
  double cpu_mt_ms = elapsed_ms(t0, Clock::now());
  bool pass_mt = verify(got_mt.data(), ref.data(), N, 1e-5f);

  // GPU prereq
  float *d_x, *d_y, *d_z;
  CUDA_CHECK(cudaMalloc(&d_x,bytes));
  CUDA_CHECK(cudaMalloc(&d_y,bytes));
  CUDA_CHECK(cudaMalloc(&d_z,bytes));

  const int threadsPerBlock = 256;
  const int numBlocks = (N + threadsPerBlock - 1) / threadsPerBlock;

  auto gpu_full = Clock::now(); // for full GPU application
  CUDA_CHECK(cudaMemcpy(d_x, x.data(), bytes, cudaMemcpyHostToDevice));
  CUDA_CHECK(cudaMemcpy(d_y, y.data(), bytes, cudaMemcpyHostToDevice));

  auto gpu_first = Clock::now(); // gpu first because first launch has startup cost
  vecadd_kernel<<<numBlocks, threadsPerBlock>>>(d_x, d_y, d_z, N);
  CUDA_CHECK(cudaDeviceSynchronize());
  double gpu_first_ms = elapsed_ms(gpu_first, Clock::now());
  CUDA_CHECK(cudaGetLastError());
  
  CUDA_CHECK(cudaMemcpy(got.data(), d_z, bytes, cudaMemcpyDeviceToHost));
  double gpu_full_ms = elapsed_ms(gpu_full, Clock::now());
  bool pass = verify(got.data(), ref.data(), N, 1e-5f);

  // GPU steady state time averaged over multiple lanches 
  const int runs = 10;
  t0 = Clock::now();
  for (int r = 0; r < runs; r++)
    vecadd_kernel<<<numBlocks, threadsPerBlock>>>(d_x,d_y,d_z,N);
  CUDA_CHECK(cudaDeviceSynchronize());
  double gpu_rest_ms = elapsed_ms(t0, Clock::now()) / runs;
  CUDA_CHECK(cudaGetLastError());

  // Metrics 
  std::printf("%s N=%d (CPU multithreaded %s)\n", pass ? "PASS" : "FAIL", N, pass_mt ? "PASS" : "FAIL");
  std::printf("blocks=%d threadsPerBlock=%d cpuThreads=%d\n", numBlocks, threadsPerBlock, T);
  std::printf("CPU sequential:           %.3f ms\n", cpu_seq_ms);
  std::printf("CPU multithreaded:        %.3f ms\n", cpu_mt_ms);
  std::printf("GPU kernel first:         %.3f ms\n", gpu_first_ms);
  std::printf("GPU kernel rest (avg %d): %.3f ms\n", runs, gpu_rest_ms);
  std::printf("GPU application:          %.3f ms (copies and first kernel)\n", gpu_full_ms);


  // Free memory
  CUDA_CHECK(cudaFree(d_x));
  CUDA_CHECK(cudaFree(d_y));
  CUDA_CHECK(cudaFree(d_z));

  return (pass && pass_mt) ? 0 : 1;
}
