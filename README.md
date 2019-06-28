# vAmiga Test Suite

<p align="center">
  <img src="http://www.dirkwhoffmann.de/vAMIGA/pics/vats1.png" height="100">
</p>

## Overview

This repo contains various Amiga example programs that have been developed for testing the vAmiga emulator. Each test consists of a disk image in ADF format and a reference image recorded with SAE. 

Most tests are modifications of Alpine9000's Amiga examples that can be found here:

https://github.com/alpine9000/amiga_examples

## vAmiga results 

### Denise

| Test          | vAmiga Result   | Remark                              | 
| ------------- | --------------- | ----------------------------------- |
| bpuoff        | Nearly passing  | DMA fine, Denise reacts too late    | 
| bpuon         | Passing         |                                     |
