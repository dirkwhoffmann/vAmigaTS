## Objective

Test some specific features of the FPU such as rounding or representing special conditions such as NaN.

#### fpuinit

Displays the reset values of all FPU registers. 

#### limits

Simple test that loads the FPU registers with the minimal and maximal values (besides others) allowed in the FMOVE.B, FMOVE.W, and FMOVE.L instructions.

#### precision1, precision2

Both tests cycle through the different precision and rounding modes. In each iteration, a value from the constant Rom is read. Afterwards, it is written back to memory in extended precision mode. Both tests differ in the point in time when FPSR is read (the contents of FPSR is displayed in the last longword of each four-longword chunk).

#### precision3

Similar test with the FMOVEM instruction. In contrast to FMOVE, no rounding takes place.

#### revcheck1

Runs a small test program that was posted here: https://forums.atariage.com/topic/192508-motorola-68881-68882-math-co-processors/page/2/
The program prints "68881" or "68882" in the first row, depending on the detected FPU revision. The second value is the size of the stack frame which differs between both revisions. 

#### special1-x

Load FP0 with special bit patterns for zero, infinity, NaN, etc. For each value, the contents of FP0 is displayed, together with the contents of the status register. 

#### special2-x

Slightly modified version of special1-x. It reads FPSR two times.

#### zflags

Moves zeroes in and out of FPU registers and checks the Z flag afterwards.


Dirk Hoffmann, 2023
