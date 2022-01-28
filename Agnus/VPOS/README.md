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

Same as vhpos3 with a single additional write to VPOSW in the initialization code. This single write is sufficient to make all frames short. 

#### lof1 and lof2

These tests set the LOF bit in VPOSW to 0 and 1 in order to force a long frame and a short frame, respectively. After that, it displays the highest line number of the frame where the LOF bit had been set.

#### probe1 - probe4

These tests probe VHPOSR at 16 different locations and display the result. Test probe2 and probe4 are special as they modifiy the ERSY bit. In probe2, ERSY is set and reset in the same scanline (which has no effect). In probe4, a scanline is crossed with ERSY equal to 1. On a real machine, this causes display corruption because the HSYNC signal is not generated. 

Dirk Hoffmann, 2019 - 2022
