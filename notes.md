# GPU Computing Notes

## 8/24 (Module 1)

Project 1: Make a correct GPU kernel run; Basic GPU Programming (Vector Addition) - 5%
Project 2: Design and optimize matrix multiplication - 10%
Project 3: Profile and improve a scientific or AI workload - 10%
Project 4: Communicate and scale across multiple GPUs - 5%
Project 5 (final project): Integrate, evaluate, explain, and defend a complete application - 5%
^ p5 has freedom 

Show and explain output, performance measurements (avg latency, problem size, hardware version etc...), figures tables (bars, curves, etc...)
^ discuss what you have learned

### Grade
Attendance Quiz: 10%
Homework: 15%
Project: 35%
Final Project: 20%
Final Exam: 20%

### Attendance Quiz
In class discuss or in class programming -> homework may be less important than in class discussion

### Final Exam 
- On paper
- Up to 4 double sided handwritten A4 paper notes (MUST BE HANDWRITTEN)
- No electronics
- No collaboration

### GPU Toolchain
- NVIDIA CUDA Toolkit and nvcc 
- CUDA Libraries, including cuBLAS and cuDNN 
- GNU C/C++ and IDE 
- NVIDIA Nsight Systems and Nsight Compute
- HiPerGator access; no hardware purchase required

### Thinking Response (QA)
**Why parallel computing became mainstream**
- Moore's Law
- Clock frequency in 2000s flatten because the heat and power has came in and then cooling became bigger problem
- 2005 frequency stopped due to the power wall because higher frequency increases energy and heat
- Single thread performance growth slowed but architecture and compiler advances continue but the old frequency driven trajectory was gone

## 8/26 (Module 1)

## For Office Hours (Friday)
Difference between Research vs Teaching?
Am I looking for research, project, just learning 
What do I want to do?
Wanting to be hired?

### Thinking Response (QA)
**Why parallel computing became mainstream**
Dennard Scaling Law: Smaller transistors enabled higher clock frequencies while keeping power density roughly constant
Under same power smaller transistors give better clock frequency until 2000s (Frequencies increasing flattened out)
We didn't need parallelism because sequencial code doubled every so often. Now it is the only solution.
TLDR: More transistors no longer meant proportionally seuqential performance

All metrics (Transistors, Frequency, Power) all slowed down so that means the Single-threaded performance growth slowed. It is called single-threaded performance bump.
We needed solution on performance of application.
Bigger cache, bigger loading, compute closer, overall layout of chips to help -> all small improvement and bounded by the physical limitation

^ Needed Multicore and parallel computing became increasingly important 
Around 2005 the number of logical cores started increasing 

Each individual core has lower frequency so heat is down and each can divide the threads so it automatically do concurrency

CPU -> Latency Oriented 
GPU -> Throughput Oriented 

CPU -> More complex Control, Cache, ALU (smaller amount)
GPU -> Simpler Control, Cache, ALU (A lot)

## 8/28 (Module 1)

DLRM (Deep Learning based Recommendation Systems) -> GPU Computing and HPC behind it

[TOP500 LINK](https://top500.org/)
^ Updates in June and December (every 5 months) -> Run Evals to see the peak performance they can achieve in terms of FLOPS

### Parallel Computing Pitfall 

Seq Exec T: 100s
Parallel Fraction: 90%
Parallelizable is 1000x faster

New time = (1 - 0.9) * 100 + (0.9 * 100) / 1000 = 10.09s
Overall speedup = 100 / 10.09 = 9.91x

Sequential portion that slows down the process: Initialize Environment, Global States

Moore's Law and Dennard Scaling

### Amdahl's Law
For an application with:
t = original sequential execution time
p = fraction of execution that is parallelizable 
s = speedup achieved on the parallelizable part 

New time = ((1-p) + p/s) * t 
Overall speedup = 1 / ((1-p) + p/s)
As s approaches infinity, maximum speedup approaches 1/(1-p)
^
Max Speedup < 1 / (1-p)

Reduce transfers, synch, launch overhead, serial setup

## 9/2 (Module 2)

### Question for the current Module 
- Where does data parallelism appear in a serial loop 
- How do the CPU and GPU divide responsibility?
- How are thousands of treads organized? 
- How does one thread find its data element?
- How do we handle boundaries, errors, and synchronous execution? 
- How should we measure whether the program is actually faster? 

### Data parallelism 

**Task Parallelism** (Different operation)
- Different operations performed on same or different data elements 
- Usually, a modest number of tasks unleashing a modest amount of parallelism 

**Data Parallelism**  (Same operation, many elements)
- The same operation applies to many different data elements 
- Potentially massive amounts of data unleashing massive amounts of parallelism 
- GPU programming often begins by finding this repeated operation

GPU Programming is typically Data Parallelism 



