
SIZES := 1 255 256 257 1000 10000000 100000000

.PHONY: all env run sanitize report clean

all: vector_add

vector_add: vector_add.cu
	nvcc -O2 -lineinfo vector_add.cu -o vector_add

vector_add_debug: vector_add.cu 
	nvcc -O0 -g -G vector_add.cu -o vector_add_debug 

env:
	hostname
	nvidia-smi
	nvcc --version 

run: vector_add 
	@for n in $(SIZES); do ./vector_add $$n || exit 1; echo; done 

sanitize: vector_add_debug
	compute-sanitizer --tool memcheck --error-exitcode 1 ./vector_add_debug 1000

report: vector_add vector_add_debug 
	@{ make -s env && make -s run && make -s sanitize; } > results.txt 2>&1; status=$$?; cat results.txt; exit $$status

clean:
	rm -f vector_add vector_add_debug results.txt
