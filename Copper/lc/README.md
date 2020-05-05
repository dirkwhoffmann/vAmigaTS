## Objective

The following test cases modify the Copper location register while DMA is off.

#### coplc1

Copper DMA is off during VSYNC. In the VBLANK interrupt handler, the location pointer is redirected and Copper DMA is switched on.

#### coplc2

Similar to coplc1, but the redirection is done outside the IRQ handler, in a line that is already visible.

#### coplc3 

This test case uses three Copper lists. It first redirects to Copper list 2, then to Copper list 3. After that, Copper DMA is enabled.

#### coplc4 

Similar to coplc3, but DMA is shortly switched on and off after the first redirection took place. 


Dirk Hoffmann, 2020
