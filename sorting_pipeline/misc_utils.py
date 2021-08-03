
import os
import tempfile
import shutil
import numpy

def mkdir2(path):
    # make a directory if it doesn't already exist
    if not os.path.exists(path):
        os.mkdir(path)

# Utility class for a temporary directory that cleans itself up
class TemporaryDirectory():
    def __init__(self):
        pass

    def __enter__(self):
        self._path = tempfile.mkdtemp()
        return self._path

    def __exit__(self, exc_type, exc_val, exc_tb):
        shutil.rmtree(self._path)

    def path(self):
        return self._path

def read_geom_csv(path):
    geom = np.genfromtxt(path, delimiter=',')
    return geom