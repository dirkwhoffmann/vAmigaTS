# vAmiga Test Suite

<p align="center">
  <img src="https://dirkwhoffmann.github.io/vAmiga/images/va-ts.png" height="100">
</p>

## Overview

This repository contains various Amiga example programs that have been developed for testing the vAmiga emulator. Each test consists of a disk image in ADF format and reference images taken on real Amigas. 

Many tests are modifications of the Amiga example programs written by Alpine9000.

## Regression testing

To run all regression tests:

1. Install TIFF tools 

    `brew install libtiff`

1. Copy Kickstart 1.3 to /tmp

    `cp /path/to/Kickstart/kick13.rom /tmp`

2. Specifiy the vAmiga executable
       
    `export VAMIGA=/path/to/the/vAmiga/executable/under/test`

3. Run tests

    `make [-j<number of parallel threads>] 2>&1 | tee results.log`

## Where to go from here?

- [Amiga emulator vAmiga](https://github.com/dirkwhoffmann/vAmiga)
- [CPU emulator Moira](https://github.com/dirkwhoffmann/Moira)
- [Amiga Examples by Alpine9000](https://github.com/alpine9000/amiga_examples)
