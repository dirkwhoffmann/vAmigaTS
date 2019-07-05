## Objective

This test modifies BPLMOD1 and BPLMOD2

### Color section 1

Registers are incremented, then decremented, and then set back to their original value.
The values are changed outside the bitplane DMA area.

### Color section 2

Same as color section 1, but the values are changed inside the bitplane DMA area.

### Color section 3

Registers are modified around the DMA cycle where modulo addition is performed.

### Color section 4

Registers are incremented and decremented by an odd value. 



