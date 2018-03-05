# Fermitools-conda-recipe

The conda recipe to build Fermi ScienceTools

```
conda build -c conda-forge -c fermi_dev_externals
```

## Documentation

### Tutorial
---------

Welcome to the wonderful - and untested(!) - world of the Fermi science tools,
now available on Linux in the *conda* package manager. This tutorial will
describe how to set up and use the fermitools under linux in this new regime. 
Let's go!

#### Anaconda
--------

The new tools relies on a distribution of Python for Scientific computing named
Anaconda. You must download and install Anaconda for python 2.7 before using
the sciencetools.

Anaconda is available on Linux, MacOS, and Windows. It comes with python2 or
python3. There is also a separate version called 'miniconda' which is just the
essentials of anaconda, it doesn't come pre-installed with the many large 
additional packages. They can all be installed through the conda package
manager.

1. `wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh`

