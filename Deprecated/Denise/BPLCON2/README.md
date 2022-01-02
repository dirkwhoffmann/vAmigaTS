## Objective

The tests in this test suite modify register BPLCON2 in various ways.

#### dualpf1 - dualpf4

These tests draw an image in dual playfield mode and iterate through all relevant values of BPLCON2. 

#### dualpf5 - dualpf8

Same as dualpf5 - dualpf8 with different scroll values in BPLCON1.

#### pri1

Single-playfield mode, PF2PRI = 0, PF1P has an illegal value

#### pri2

Single-playfield mode, PF2PRI = 0, PF2P has an illegal value

#### pri3

Single-playfield mode, PF2PRI = 0, both PF1P and PF2P have an illegal value

Observation: Setting both PF1P and PF2P to illegal values in single-playfield mode causes the video output to break down. 

#### pri4 to pri6

Same as pri1 to pri3 with PF2PRI = 1.

#### pri7 and pri8

Same as pri3 with other background images. 

#### pri9 and pri10 

Same as pri8 with illegal values 5 and 6 instead of 7.


Dirk Hoffmann, 2019 - 2020
