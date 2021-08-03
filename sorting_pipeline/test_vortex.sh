#!/bin/bash

export NUM_WORKERS_PER_JOB=2
export MKL_NUM_THREADS=$NUM_WORKERS_PER_JOB
export NUMEXPR_NUM_THREADS=$NUM_WORKERS_PER_JOB
export OMP_NUM_THREADS=$NUM_WORKERS_PER_JOB

./sort_animal_day.py --input /vortex2/jason/kf19/preprocessing/20170913 --output test_output --num_jobs 4 --test $@