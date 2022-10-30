## Objective

Verfify the collision detection bits.

#### sprcoll1 - sprcoll8

These test cases perform multiple sprite/sprite and sprite/playfield collision tests with varying values in CLXCON and visualizes the contents of CLXDAT in form of color bars.

#### sprcoll1d - sprcoll8d

Same as  sprcoll1 - sprcoll6 in dual-playfield mode.

sprcol8 and sprcol8d exhibit a hardware oddity: If playfield 2 doesn't match in single-playfield mode, playfield 1 can't match either. In dual-playfield mode, everything works as expected. 


Dirk Hoffmann, 2020
