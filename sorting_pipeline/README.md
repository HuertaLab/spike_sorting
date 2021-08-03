# franklab_sorting_pipeline

Parallelized spike sorting pipeline for use in Loren Frank's lab, specifically for Hannah and Jason's data.

The basic functionality is to input a directory representing a single animal day of ephys data and to obtain an output directory containing the spike sorting results.

## Installation and setup

Create a fresh conda environment with python 3.7

```
conda create -n [some_name] python=3.7
conda activate [some_name]
```

(Python 3.6 should also work)

Install the following packages

```
conda install ml_ms3
pip install spikeforest
pip install ml_ms4alg
```

The ml_ms3 package was created by Tom and contains some old processors that have not yet been replicated in pure Python. The plan is to eventually migrate away from this dependency.

**Important**: do not install the ml_ms4alg conda package in this environment (from the flatiron channel) because it conflicts with the PyPI version of ml_ms4alg.

You should set the following environment variables in your .bashrc file

```
export SHA1_CACHE_DIR=[/some/directory/for/temp/files/unique/to/your/user]
export ML_TEMPORARY_DIRECTORY=[/some/other/directory/for/temp/files/unique/to/your/user]
```

Note: If multiple users try to set the same temporary directories, there will be a permissions conflict.

## Usage

The main script is [sort_animal_day.py](./sort_animal_day.py), but you should create a bash script (.sh file) that sets some environment variables and calls the main python script. See for example: [test_vortex.sh](./test_vortex.sh).

For info on the arguments to pass to the Python script, run:

```
./sort_animal_day.py --help
```

## Going forward

It is intended that users will adapt the .sh and .py scripts to their own needs and that this script (or versions of it) will improve over time. The following improvements are needed:

* Expose additional sorting parameters as command-line arguments to the Python script.

* Write a log file to the output directory with info on which parameters were used to perform the sorting. This should just be a few lines added to the script.

* Add ability to simultaneously sort the entire animal day (sort a concatenated file).

* Migrate away from using ml_ms3 conda package (toward pure python solution)

* Add ability to swap in other sorters supported by [SpikeToolkit](https://github.com/SpikeInterface/spiketoolkit). Caution: Care must be taken in which version of spiketoolkit is installed.

Please submit other requests via github issues.

## Who maintains this repo?

It expected that members of the Frank lab will maintain and update it. Contact Jeremy to be added to the repo.

All users are responsible for updating this repo when clarifications or fixes need to be made by submitting [pull requests](https://help.github.com/en/articles/creating-a-pull-request-from-a-fork) or making notes in the github issue tracker.


