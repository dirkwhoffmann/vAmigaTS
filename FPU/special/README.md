## Objective

Test some specific features of the FPU such as rounding or representing special conditions such as NaN.

#### precision1, precision2

Both tests cycle through the different precision and rounding modes. In each iteration, a value from the constant Rom is read. Afterwards, it is written back to memory in extended precision mode. Both tests differ in the point in time when FPSR is read (the contents of FPSR is displayed in the last longword of each four-longword chunk).

#### precisionm3

Similar test with the FMOVEM instruction. In contrast to FMOVE, no rounding takes place.

#### special1-x

Load FP0 with special bit patterns for zero, infinity, NaN, etc. For each value, the contents of FP0 is displayed, together with the contents of the status register. 


Dirk Hoffmann, 2023
