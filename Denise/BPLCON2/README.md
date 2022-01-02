## Objective

The tests in this test suite modify register BPLCON2 in various ways.

#### dualpf1 - dualpf4

These tests draw an image in DPF+HAM mode (6 bitplanes) and iterate through all possible values of the lower 7 bits in BPLCON2 (PF1P0 - PF2PRI). 

#### dualpf5 - dualpf8

Same as dualpf1 - dualpf4 with different scroll values in BPLCON1.

#### dualpf9 - dualpf12

Same as dualpf5 - dualpf8 with 5 bitplanes and HAM mode disabled. 


Dirk Hoffmann, 2019 - 2021
