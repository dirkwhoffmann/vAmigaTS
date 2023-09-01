## Objective

Verify the proper handling of values in packed BCD format.

#### pflags*n*

Loads some special bit patterns in packed BCD format and displays the status register. The bit patterns have been selected to make certain flags to be set.

#### packed*n*

Reads various values in packed format (.p) and writes them back into memory in extended format (.x). 

- packed1, packed2: Uses some standard bit pattern
- packed3, packed4: Bit patterns contain invalid BCD digits (A - F)
- packed5, packed6: Uses special bit patterns (e.g., e = 'FFF' to signal inf and nan)
- packed7: Uses BCD-coded numbers having an exact representation in binary

#### kfactor*n*-*cr*

Writes a constant into memory in packed BCD format and different k-factors. cr is the initial value of FPCR and selects different rounding modes. 

#### pprec*n* 

Reads in a packed BCD string close to FLOAT_MAX and DOUBLE_MAX with different rounding modes activated.


Dirk Hoffmann, 2023
