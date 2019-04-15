from distutils.core import setup
from Cython.Build import cythonize

setup(name='Minicactpot Solver',
      ext_modules=cythonize("main.pyx",annotate=True)
      )