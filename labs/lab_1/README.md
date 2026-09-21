# Lab 1 - GPU Vector Addition 

## Workflow 

Run the following:
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
- Had issues on report output originally as i did `3.f` instead of `.3f`.
  - It was just reading the lines again line by line to find out why there was an issue.
- Had issues with Makefile and doing it so that it will generate report easily.
  - I had some AI assistance within this process as it has been a while writing bash scripts.

## AI assistance 
- I had AI assistance especially in the help of fixing my Makefile as it has been some time since I've written bash scripts in such a manner. It helped me specifically for the run and report commands.

## Test Cases 

I did it on both my local computer and HiperGator. My local computer has 4070 NVIDIA GPU and ran on WSL. 

### HiperGator 


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
