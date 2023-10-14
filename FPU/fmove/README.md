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

#### fmove5-*format*

The contents of a data register is transferred into a FPU register. Note: This operation is only availabe for addressing modes .b, .w, .l, and .s.

#### fmove-nan-1

Loads some reserved bit patterns and writes them back in different format. 


Dirk Hoffmann, 2023
