## Objective

### col1

Changes some color registers to verify color register and Copper timing. The test contains of two parts. 

The first part changes color register 10 at incrementing horizontal positions. As can be seen in the reference image, the result is not a straight line. It is interrupted by a jump which is caused by bitplane DMA blocking the Copper.

The second part draws a long line that crosses the HSYNC boundary. It can be used to verify that the Copper is blocked at cycle $E2. This cycle is a refresh cycle and therefore always blocked.
