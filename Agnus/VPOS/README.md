## Objective

Visualize the value of the position registers 

#### vpos2

During vBlank, VPOSR is read. The contents is visualized in form of color bars.

#### vhposr1

This test triggers four interrupts per frame. The first interrupt syncs the CPU to get reproducable results. The other three handlers read VHPOSR and visualize the lower 4 bits in form of different colors.


Dirk Hoffmann, 2019
