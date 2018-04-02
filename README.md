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

1. Open a Terminal on your linux machine.
1. Curl the download script like so: `curl -s -L
   https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh >
   miniconda.sh`
1. Decide on a home location for your anaconda install. A good choice is your
   home directory.
1. Execute the install script and install to your home like so: `bash
   miniconda.sh -b -p $HOME/anaconda`
1. Add the executables in this new directory to your path. In bash this is
   `export PATH=$HOME/anaconda/bin:$PATH`.  In tcsh this is `setenv PATH
   $HOME/anaconda/bin:$PATH`. It is a good idea to add this to your personal
   .bashrc or .tcshrc file now as well.
1. Install the fermitools into a new conda environment named fermi.
  `conda create -n fermi -c conda-forge -c fermi_dev_externals fermitools`
1. Respond `y` for yes when prompted to proceed.
1. Activate this environment with `source activate fermi`.
1. Now you should have access to the Sciencetools!
1. If you want to install conflicting packages you can `source deactivate` your environment and `conda create` a new one.


