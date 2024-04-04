# build .pyx modules

from distutils.core import setup
from Cython.Build import cythonize
import numpy as np

setup(
    ext_modules=cythonize("cython-modules/garchlogl.pyx"),
    include_dirs=[np.get_include()]
)