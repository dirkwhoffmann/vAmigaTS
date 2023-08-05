## Objective

Executes different variants of the FMOVE instruction.

#### fmove-fpcr

Moves some values into the three FPU registers (FPCR, FPSR, and FPIAR) and reads them back. The test shows that unused bits are masked out by the move operation.

#### fmove1-*format*

The programs loads FP0 with a constant (Pi) from the FPU's constant Rom and writes the value into memory via FMOVE. The process is repeated 24 times with different values in the floating-point control register (FPCR). 

#### fmove1-pipd

Executes the FMOVE instruction in combination with the post-increment and pre-decrement addressing modes.

#### fmove2-*format*, fmove2-pipd

Similar to fmove1 with a negative payload.

#### fmove3-*format*, fmove3-pipd

A floating-point value is read via immediate addressing mode and written back.

#### fmove4-*format*

A floating-point value is read from memory and written back. 

#### packed*n*

Reads various values in packed format (.p) and writes them back into memory in extended format (.x). packed3 and above utilize unusual bit patterns (e.g., patterns with BCD-Digits greater than 9). 

#### precision1, precision2

Both tests cycle through the different precision and rounding modes. In each iteration, a value from the constant Rom is read. Afterwards, it is written back to memory in extended precision mode. Both tests differ in the point in time when FPSR is read (the contents of FPSR is displayed in the last longword of each four-longword chunk).


Dirk Hoffmann, 2023
