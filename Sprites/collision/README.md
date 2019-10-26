## Objective

Verfify the collision detection bits

#### collision1 to collision7

This tests draws two overlapping sprites. One of the two sprites overlaps a portion of the playfield, too. During vBlank, the CLXDAT register is read and split into four 4-bit chunks. After that, the chunks are written into color registers 0 to 3 to make the bit-pattern visible. The test is carried out with different sprite numbers and different values in CLXCON. 

#### collision5s and collision5d

Like collosion5 without toggling between single-playfield and dual-playfield mode. collision5s draws solely in single-playfield mode and collision5d solely in dual-playfield mode.


Dirk Hoffmann, 2019
