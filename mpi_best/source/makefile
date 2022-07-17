all: revGOL gol 

CC:=mpicc
EXT:=c
FLAGS:= -O3 -lm -lpng

reverseGOL.o: reverseGOL-mpi.$(EXT)
	$(CC) $(FLAGS) -c reverseGOL-mpi.$(EXT) 

png_util.o: png_util.c
	$(CC) $(FLAGS) -c png_util.c

revGOL: reverseGOL-mpi.o png_util.o
	$(CC) $(FLAGS) -o revGOL reverseGOL-mpi.o png_util.o

gameoflife.o: gameoflife.$(EXT)
	$(CC) $(FLAGS) -c gameoflife.$(EXT) 

gol: gameoflife.o png_util.o
	$(CC) $(FLAGS) -o gol gameoflife.o png_util.o

test: revGOL data.txt
	./revGOL data.txt

clean:
	rm *.o
	rm gol 
	rm revGOL 
