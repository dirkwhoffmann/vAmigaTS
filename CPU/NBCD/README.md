## Objective

Verify properties of the NBCD intruction.

#### nbcd1

Draws two 16 x 16 squares. In each square, the NBCD command is run for all 256 possible source values. The left square has the X flag cleared and the right square set. Each 8 x 8 pixel box shows the bit pattern of value computed by instruction under test.

#### nbcd2 

Displays the value of the N flag after NBCD has been executed. 
The N flag is of special interest, because it's value is described as undefined in the reference manual.

#### nbcd3

Displays the value of the V flag after NBCD has been executed. 
The V flag is of special interest, because it's value is described as undefined in the reference manual.

#### nbcd4

Displays the value of the X,Z, and V flag after NBCD has been executed. 

Dirk Hoffmann, 2019
