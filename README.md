# spike_sorting

This repository contains files to use convert Neuralynx .ncs files into the .mda format for MountainSort, run the MountainSort pipeline, and convert the sorted spike files into text files containing unitID,timestmap pairs. 

More information on MountainSort can be found at: https://github.com/flatironinstitute/mountainsort_examples/blob/master/README.md

In order to run the scripts included here, the mdaio (link below) folder must be downloaded and listed in the file path. This folder contains the .m files needed to read and write .mda files.
https://github.com/flatironinstitute/mountainlab/tree/master/matlab/mdaio

More information on mda files can be found at: https://github.com/flatironinstitute/mountainlab/blob/master/docs/source/mda_file_format.rst

To import Neuralynx data into MATLAB, use the MEX files which can be downloaded at: https://neuralynx.com/software/category/matlab-netcom-utilities
