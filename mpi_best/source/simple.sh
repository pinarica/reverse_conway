#!/bin/bash --login

make clean 
make 

time mpirun -np 50 ./revGOL cmse2.txt

