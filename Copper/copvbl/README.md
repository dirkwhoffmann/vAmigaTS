 ## Objective

Verfies certain timing properties at vsync. 

#### copnonstop

The Copper is started at the end of a frame without an terminating wait statement. The test can be used to verify at which statement execution is stopped by Agnus. 

#### copvbl*x*

These tests utilize to Copper to trigger an interrupt at a positon close to the end of the current frame. In the interrupt handler, the CPU is used to produce some color stripes in a loop. After the loop has terminated, one of the two beam position registers are read (VPOSR or VHPOSR) and the value is displayed in form of a bit pattern. 


Dirk Hoffmann, 2019 - 2020
