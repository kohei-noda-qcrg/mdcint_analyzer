# MDCINT analyzer

This program provides you utilities to analyze [DIRAC](http://diracprogram.org) MDCINT file.
# Download

```sh
git pull https://github.com/kohei-noda-qcrg/mdcint_analyzer.git
```

# Build

- gfortran
  ```sh
  FC=gfortran make
  ```
- intel fortran
  ```sh
  make
  ```

# How to use

- First, you need to convert MDCINT file to formatted style
  ```sh
  ./readmdcint
  ```
This program creates a file named "debug" (a formatted MDCINT file).

- sort_mdcint sorts a formatted file and picks up two-electron integers of a specific type.
  - See sort_mdcint --help for more information

  (e.g.)
    ```sh
    # Sort and output only all indices are natural numbers from 1 to 10
    ./sort_mdcint -i formatted -p="++++" -r 1 10
    ```
    
- get_diff_mdcint checks the differences between two MDCINT files
  - See get_diff_mdcint --help for more information
  
  (e.g.)
  ```sh
  # Get difference between the two files (i.e. A - B)
  ./get_diff_mdcint -i A B --diff
  ```
