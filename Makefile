SHELL     := /bin/bash
CXX       := g++
CXXFLAGS  := -std=c++20 -O2 -Wall -Wextra
NVCC      := nvcc
NVCCFLAGS := -std=c++20 -O2 -arch=native

# FILE: program for `make run`   PROGS: programs for `make compare`
# ARGS: arguments passed to the program
# RUNS/WARMUP: timed runs per program, and untimed runs discarded before them
FILE   ?= test
ARGS   ?=
PROGS  ?=
RUNS   ?= 10
WARMUP ?= 2

# every .cpp / .cu here is a buildable target: `make vecadd`
BINS := $(basename $(wildcard *.cpp) $(wildcard *.cu))

.PHONY: all run compare list clean
all: $(BINS)

%: %.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
%: %.cu
	$(NVCC) $(NVCCFLAGS) $< -o $@

run: $(FILE)
	./$(FILE) $(ARGS)

list:
	@echo "buildable: $(BINS)"

clean:
	rm -f $(BINS)

# make compare PROGS="cpu gpu gpu_tiled" [RUNS=20] [ARGS="1024 32"]
compare: $(PROGS)
	@test -n "$(PROGS)" || { echo 'usage: make compare PROGS="p1 p2 ..." [RUNS=20] [ARGS=...]'; exit 1; }
	@echo "$(RUNS) timed runs each ($(WARMUP) warm-up), wall clock per process"
	@set -o pipefail; for p in $(PROGS); do \
	  for i in $$(seq $$(($(WARMUP) + $(RUNS)))); do \
	    t0=$$(date +%s%N); \
	    ./$$p $(ARGS) >/dev/null 2>&1 || { echo "error: ./$$p exited non-zero" >&2; exit 1; }; \
	    t1=$$(date +%s%N); \
	    [ $$i -gt $(WARMUP) ] && echo "$$p $$(((t1 - t0) / 1000))"; \
	  done; \
	done | awk \
	  '{ if (!($$1 in id)) { id[$$1] = ++k; name[k] = $$1 } \
	     i = id[$$1]; n[i]++; s[i] += $$2; q[i] += $$2 * $$2; \
	     if (n[i] == 1 || $$2 < lo[i]) lo[i] = $$2 } \
	   END { printf "%-20s %12s %12s %12s %10s\n", \
	           "program", "mean (ms)", "min (ms)", "sd (ms)", "speedup"; \
	         for (i = 1; i <= k; i++) { \
	           m = s[i] / n[i]; v = q[i] / n[i] - m * m; if (v < 0) v = 0; \
	           printf "%-20s %12.3f %12.3f %12.3f %9.2fx\n", \
	             name[i], m/1000, lo[i]/1000, sqrt(v)/1000, (s[1]/n[1]) / m } }'
