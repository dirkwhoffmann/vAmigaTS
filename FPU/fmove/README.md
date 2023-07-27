## Objective

Executes different variants of the FMOVE instruction.

#### fmove1-*format*

The programs loads FP0 with a constant (Pi) from the FPU's constant Rom and writes the value into memory via FMOVE. The process is repeated 24 times with different values in the floating-point control register (FPCR). 

#### fmove1-pipd

Executes the FMOVE instruction in combination with the post-increment and pre-decrement addressing modes.

#### fmove2-*format*, fmove2-pipd

Similar to fmove1 with a negative payload.

#### fmove3-*format*, fmove3-pipd

Similar to fmove1. Instead of loading the constant from constant Rom, it is loaded via fmove #*value*.

#### fmovecr-*n*

Reads and displays a constant from constant Rom.


Dirk Hoffmann, 2023
