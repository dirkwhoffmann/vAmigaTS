## Objective

Executes different variants of the FMOVE instruction.

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

#### fmovecr*n*

Reads and displays a constant from constant Rom. fmovecr3 and above read from undocumented constant space (reserved space which is marked for further expansion). 

#### packed*n*

Reads various values in packed format (.p) and writes them back into memory in extended format (.x). packed3 and above utilize unusual bit patterns (e.g., patterns with BCD-Digits greater than 9). 


Dirk Hoffmann, 2023
