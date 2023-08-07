## Objective

Executes different variants of the FMOVECR instruction (move from constant ROM).

#### fmovecr*n*

Reads and displays a constant from the constant Rom.

#### fmovecr*n*-*cr*

Variants of fmovecr*n*. fmovecr3-*cr* and above read from undocumented constant space (reserved space which is marked for further expansion). *cr* is the setup value for the FPCR register. The value is modified in order to test different rounding modes.  


Dirk Hoffmann, 2023
