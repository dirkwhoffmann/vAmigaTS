## Objective

Visualize the value of the position registers 

#### vhpos1

Reads VPOSR in the VBLANK interrupt handler and visualizes the result in form of color bars. 

#### vhpos2

Reads VHPOSR in the VBLANK interrupt handler and visualizes the result in form of color bars. 

#### vhpos3

Reads the TOD counter of CIAB (CIAB counts lines)  in the VBLANK interrupt handler and visualizes the result in form of color bars. The TOD clock is reset after it is read.

#### vhpos4 

Same as vhpos3 with an additional write to VPOSW in the interrupt handler. The write makes every frame a short frame by clearing the uppermost bit. 

#### vhpos5 

Same as vhpos3 with a single additional write to VPOSW in the initialization code. This single write is sufficient to make all frames
short. 

#### vhposr1

This test triggers four interrupts per frame. The first interrupt syncs the CPU to get reproducable results. The other three handlers read VHPOSR and visualize the lower 4 bits in form of different colors.

#### lof1 and lof2

These tests set the LOF bit in VPOSW to 0 and 1 in order to force a long frame and a short frame, respectively. After that, it displays the highest line number of the frame where the LOF bit had been set.


Dirk Hoffmann, 2019 - 2020
