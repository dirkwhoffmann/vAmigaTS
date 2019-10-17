## Objective

Visualize the value of the position registers 

#### vpos1 (deprecated)

During vBlank, VPOSR is read and split into four 4-bit chunks. After that, the chunks are written into color registers 0 to 3 to make the bit-pattern visible. The color values exhibit the identification bits of Agnus and Denise that are part of this register.

#### vpos2

This test visualizes the contents of VPOSR in form of color bars. It makes vpos1 obsolete.

Dirk Hoffmann, 2019
