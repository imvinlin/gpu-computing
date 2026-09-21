# Lab 1 - GPU Vector Addition 

## Workflow 

HiperGator:
```bash 
sbatch lab1.slurm 
```

Local workflow:
```bash 
make # builds vector_add (nvcc -O2 -lineinfo)
./vector_add 1000
make run # runs all the test sizes
make sanitize # debug build + computer-sanitizer memcheck
make report # full report with env + all tests + sanitizer and saves result to results.txt 
```

## Evidence that the GPU result matches the CPU reference
- The output for both the GPU and CPU were compared element by element with the 1e-5 tolerance.
- Multithreaded CPU output is checked in the same way 
- All test sizes passed
- Compute Sanitizer memcheck showed 0 errors for HiperGator

## A short explanation of one problem encountered and how it was resolved
- Not much GPU/CPU issues that were encountered in the process 
- Had issues on report output originally as i did `3.f` instead of `.3f`
  - It was just reading the lines again line by line to find out why there was an issue
- Had issues with Makefile and doing it so that it will generate report easily
  - I had some AI assistance within this process as it has been a while writing bash scripts

## AI assistance 
- I had AI assistance especially in the help of fixing my Makefile as it has been some time since I've written bash scripts in such a manner. It helped me specifically for the run and report commands
- I also used AI assistance in fixing the slurm file to be able to allocate GPU
- I used AI assistance in making a markdown friendly compact table as I have already grabbed the data with the report command. However, AI was used to make compact table look nice

## Slide 19 Ceiling Division 
- With plain integer division `257 / 256 = 1` block gives only 256 threads so element 256 is never computed
- However, `(N + 255) / 256` rounds up and the `if (i < N)` guards stops the extra threads

## Test Cases, Launch Configuration, and Results

Launch configuration for every test: `threadsPerBlock = 256`, `numBlocks = (N + 256 - 1) / 256`.
All times in ms.

### HiPerGator (NVIDIA L4, node c0610a-s9, CUDA 13.2, driver 580.178.04)

| N | Case | Blocks | Threads launched | Result | CPU seq | CPU MT | GPU kernel first | GPU kernel rest (avg 10) | GPU full |
|---:|---|---:|---:|:---:|---:|---:|---:|---:|---:|
| 1 | Single element | 1 | 256 | PASS | 0.000 | 1.998 | 36.636 | 0.002 | 37.002 |
| 255 | Smaller than one block | 1 | 256 | PASS | 0.000 | 1.397 | 2.572 | 0.002 | 2.608 |
| 256 | Exactly one block | 1 | 256 | PASS | 0.000 | 1.250 | 2.214 | 0.003 | 2.255 |
| 257 | One more than one block | 2 | 512 | PASS | 0.000 | 1.331 | 2.223 | 0.002 | 2.259 |
| 1,000 | Not divisible by block size | 4 | 1,024 | PASS | 0.000 | 1.409 | 2.135 | 0.002 | 2.172 |
| 10,000,000 | Large, many blocks | 39,063 | 10,000,128 | PASS | 2.948 | 2.296 | 2.733 | 0.490 | 9.087 |
| 100,000,000 | Very large | 390,625 | 100,000,000 | PASS | 29.586 | 16.782 | 7.136 | 5.105 | 61.774 |

Compute Sanitizer memcheck (`N = 1000`, debug build): **0 errors**

### Local (NVIDIA GeForce RTX 4070, WSL2, CUDA 13.1, driver 591.59)

| N | Case | Blocks | Threads launched | Result | CPU seq | CPU MT | GPU kernel first | GPU kernel rest (avg 10) | GPU full |
|---:|---|---:|---:|:---:|---:|---:|---:|---:|---:|
| 1 | Single element | 1 | 256 | PASS | 0.000 | 0.598 | 0.314 | 0.007 | 0.676 |
| 255 | Smaller than one block | 1 | 256 | PASS | 0.000 | 0.631 | 0.148 | 0.004 | 0.474 |
| 256 | Exactly one block | 1 | 256 | PASS | 0.000 | 0.582 | 0.200 | 0.006 | 0.569 |
| 257 | One more than one block | 2 | 512 | PASS | 0.000 | 0.674 | 0.232 | 0.012 | 0.649 |
| 1,000 | Not divisible by block size | 4 | 1,024 | PASS | 0.000 | 0.540 | 0.282 | 0.010 | 0.586 |
| 10,000,000 | Large, many blocks | 39,063 | 10,000,128 | PASS | 4.552 | 2.078 | 0.487 | 0.250 | 10.645 |
| 100,000,000 | Very large | 390,625 | 100,000,000 | PASS | 42.548 | 18.538 | 2.688 | 2.574 | 97.492 |

Compute Sanitizer: not supported on GPUs under WSL (WDDM), so memcheck was run on HiPerGator only

### Column definitions

- **Threads launched**: `numBlocks * 256`. Threads with `i >= N` are stopped by the `if (i < N)` guard
- **CPU seq**: sequential `vecadd_cpu` (also the correctness reference)
- **CPU MT**: `vecadd_cpu_mt` using `std::thread::hardware_concurrency()` threads (96 on HiPerGator but i did --cpus-per-task=8, 24 locally)
- **GPU kernel first**: first kernel launch + `cudaDeviceSynchronize()`, includes one time startup cost
- **GPU kernel rest**: average of the next 10 runs so it will be the steady state
- **GPU full**: host-to-device copies + first kernel + device-to-host copy which excludes `cudaMalloc` / `cudaFree`

## RAW Test Case with report command

### HiperGator 
```bash 

c0610a-s9.ufhpc
Mon Sep 21 00:39:55 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 580.178.04             Driver Version: 580.178.04     CUDA Version: 13.2     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA L4                      On  |   00000000:C1:00.0 Off |                    0 |
| N/A   32C    P8             15W /   70W |       0MiB /  23034MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2026 NVIDIA Corporation
Built on Thu_Mar_19_11:12:51_PM_PDT_2026
Cuda compilation tools, release 13.2, V13.2.78
Build cuda_13.2.r13.2/compiler.37668154_0
PASS N=1 (CPU multithreaded PASS)
blocks=1 threadsPerBlock=256 cpuThreads=96
CPU sequential:           0.000 ms
CPU multithreaded:        1.998 ms
GPU kernel first:         36.636 ms
GPU kernel rest (avg 10): 0.002 ms
GPU application:          37.002 ms (copies and first kernel)

PASS N=255 (CPU multithreaded PASS)
blocks=1 threadsPerBlock=256 cpuThreads=96
CPU sequential:           0.000 ms
CPU multithreaded:        1.397 ms
GPU kernel first:         2.572 ms
GPU kernel rest (avg 10): 0.002 ms
GPU application:          2.608 ms (copies and first kernel)

PASS N=256 (CPU multithreaded PASS)
blocks=1 threadsPerBlock=256 cpuThreads=96
CPU sequential:           0.000 ms
CPU multithreaded:        1.250 ms
GPU kernel first:         2.214 ms
GPU kernel rest (avg 10): 0.003 ms
GPU application:          2.255 ms (copies and first kernel)

PASS N=257 (CPU multithreaded PASS)
blocks=2 threadsPerBlock=256 cpuThreads=96
CPU sequential:           0.000 ms
CPU multithreaded:        1.331 ms
GPU kernel first:         2.223 ms
GPU kernel rest (avg 10): 0.002 ms
GPU application:          2.259 ms (copies and first kernel)

PASS N=1000 (CPU multithreaded PASS)
blocks=4 threadsPerBlock=256 cpuThreads=96
CPU sequential:           0.000 ms
CPU multithreaded:        1.409 ms
GPU kernel first:         2.135 ms
GPU kernel rest (avg 10): 0.002 ms
GPU application:          2.172 ms (copies and first kernel)

PASS N=10000000 (CPU multithreaded PASS)
blocks=39063 threadsPerBlock=256 cpuThreads=96
CPU sequential:           2.948 ms
CPU multithreaded:        2.296 ms
GPU kernel first:         2.733 ms
GPU kernel rest (avg 10): 0.490 ms
GPU application:          9.087 ms (copies and first kernel)

PASS N=100000000 (CPU multithreaded PASS)
blocks=390625 threadsPerBlock=256 cpuThreads=96
CPU sequential:           29.586 ms
CPU multithreaded:        16.782 ms
GPU kernel first:         7.136 ms
GPU kernel rest (avg 10): 5.105 ms
GPU application:          61.774 ms (copies and first kernel)

========= COMPUTE-SANITIZER
PASS N=1000 (CPU multithreaded PASS)
blocks=4 threadsPerBlock=256 cpuThreads=96
CPU sequential:           0.001 ms
CPU multithreaded:        1.299 ms
GPU kernel first:         18.619 ms
GPU kernel rest (avg 10): 0.039 ms
GPU application:          18.987 ms (copies and first kernel)
========= ERROR SUMMARY: 0 errors
```

### Local Report (4070 + WSL)
```bash
DESKTOP-2V295E4
Mon Sep 21 00:23:23 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 590.48.01              Driver Version: 591.59         CUDA Version: 13.1     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 4070        On  |   00000000:01:00.0  On |                  N/A |
|  0%   33C    P8             14W /  200W |    1819MiB /  12282MiB |     19%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A             829      G   /Xwayland                             N/A      |
+-----------------------------------------------------------------------------------------+
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2025 NVIDIA Corporation
Built on Tue_Dec_16_07:23:41_PM_PST_2025
Cuda compilation tools, release 13.1, V13.1.115
Build cuda_13.1.r13.1/compiler.37061995_0
PASS N=1 (CPU multithreaded PASS)
blocks=1 threadsPerBlock=256 cpuThreads=24
CPU sequential:           0.000 ms
CPU multithreaded:        0.598 ms
GPU kernel first:         0.314 ms
GPU kernel rest (avg 10): 0.007 ms
GPU application:          0.676 ms (copies and first kernel)

PASS N=255 (CPU multithreaded PASS)
blocks=1 threadsPerBlock=256 cpuThreads=24
CPU sequential:           0.000 ms
CPU multithreaded:        0.631 ms
GPU kernel first:         0.148 ms
GPU kernel rest (avg 10): 0.004 ms
GPU application:          0.474 ms (copies and first kernel)

PASS N=256 (CPU multithreaded PASS)
blocks=1 threadsPerBlock=256 cpuThreads=24
CPU sequential:           0.000 ms
CPU multithreaded:        0.582 ms
GPU kernel first:         0.200 ms
GPU kernel rest (avg 10): 0.006 ms
GPU application:          0.569 ms (copies and first kernel)

PASS N=257 (CPU multithreaded PASS)
blocks=2 threadsPerBlock=256 cpuThreads=24
CPU sequential:           0.000 ms
CPU multithreaded:        0.674 ms
GPU kernel first:         0.232 ms
GPU kernel rest (avg 10): 0.012 ms
GPU application:          0.649 ms (copies and first kernel)

PASS N=1000 (CPU multithreaded PASS)
blocks=4 threadsPerBlock=256 cpuThreads=24
CPU sequential:           0.000 ms
CPU multithreaded:        0.540 ms
GPU kernel first:         0.282 ms
GPU kernel rest (avg 10): 0.010 ms
GPU application:          0.586 ms (copies and first kernel)

PASS N=10000000 (CPU multithreaded PASS)
blocks=39063 threadsPerBlock=256 cpuThreads=24
CPU sequential:           4.552 ms
CPU multithreaded:        2.078 ms
GPU kernel first:         0.487 ms
GPU kernel rest (avg 10): 0.250 ms
GPU application:          10.645 ms (copies and first kernel)

PASS N=100000000 (CPU multithreaded PASS)
blocks=390625 threadsPerBlock=256 cpuThreads=24
CPU sequential:           42.548 ms
CPU multithreaded:        18.538 ms
GPU kernel first:         2.688 ms
GPU kernel rest (avg 10): 2.574 ms
GPU application:          97.492 ms (copies and first kernel)

========= COMPUTE-SANITIZER
========= Error: Failed to initialize WDDM debugger interface. Please run EnableDebuggerInterface.bat as an administrator
========= 
========= Error: Device not supported. Please refer to the "Supported Devices" section of the sanitizer documentation
========= 
PASS N=1000 (CPU multithreaded PASS)
blocks=4 threadsPerBlock=256 cpuThreads=24
CPU sequential:           0.001 ms
CPU multithreaded:        0.595 ms
GPU kernel first:         0.399 ms
GPU kernel rest (avg 10): 0.023 ms
GPU application:          0.601 ms (copies and first kernel)
========= ERROR SUMMARY: 2 errors
make[1]: *** [Makefile:23: sanitize] Error 1
```
```
