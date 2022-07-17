#!/bin/bash --login

mv *.out parallel_out

make clean -C source
make -C source


