# vAmiga Test Suite

<p align="center">
  <img src="https://dirkwhoffmann.github.io/vAmiga/images/va-ts.png" height="100">
</p>

## Overview

This repo contains various Amiga example programs that have been developed for testing the vAmiga emulator. Each test consists of a disk image in ADF format and reference images taken from other emulators. Most tests come with an additional screenshot taken from a real A500. 

Many tests are modifications of the Amiga example programs written by Alpine9000.

Directory cputester contains various ADFs that have been created with the cputester tool written by Toni Wilen. All disks have been set up to auto-boot and test a single instruction each. 

## Automatic regression testing

This repo also contains multiple Makefiles for performing automatic regression tests. To run the tests, make sure to let variable VAMIGA in the top-level Makefile point to the vAmiga executable under test.

## Where to go from here?

- [vAmiga Emulator](https://github.com/dirkwhoffmann/vAmiga)
- [Amiga Examples by Alpine9000](https://github.com/alpine9000/amiga_examples)
