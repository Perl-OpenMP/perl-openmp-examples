all: pi pi2

pi:
	gcc -fopenmp ./src/omp-pi.c -o ./bin/omp-pi.x

pi2:
	gcc -fopenmp ./src/omp-pi-2.c -o ./bin/omp-pi-2.x

run: pi2
	./scripts/pi.sh
	./scripts/pi.pl
	./inline/omp-pi-2.pl
	./inline/omp-pi-3.pl
	./inline/omp-pi.pl

clean:
	rm -rvf ./bin/*.x ./_Inline
