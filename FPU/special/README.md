## Objective

Test some specific features of the FPU such as rounding or representing special conditions such as NaN.

#### precision1, precision2

Both tests cycle through the different precision and rounding modes. In each iteration, a value from the constant Rom is read. Afterwards, it is written back to memory in extended precision mode. Both tests differ in the point in time when FPSR is read (the contents of FPSR is displayed in the last longword of each four-longword chunk).

#### precisionm1, precisionm2

Same as precision1 and precision2, but with FMOVEM instead of FMOVE.


Dirk Hoffmann, 2023
