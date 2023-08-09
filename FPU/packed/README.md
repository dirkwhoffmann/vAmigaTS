## Objective

Verify the proper handling of values in packed BCD format.

#### pflags*n*

Loads some special bit patterns in packed BCD format and displays the status register. The bit patterns have been selected to make certain flags to be set.

#### packed*n*

Reads various values in packed format (.p) and writes them back into memory in extended format (.x). packed3 and above utilize unusual bit patterns (e.g., patterns with BCD-Digits greater than 9). 

#### kfactor*n*-*cr*

Writes a constant into memory in packed BCD format and different k-factors. cr is the initial value of FPCR and selects different rounding modes. 


Dirk Hoffmann, 2023
