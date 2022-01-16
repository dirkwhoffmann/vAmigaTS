## Objective

The tests in this test suite modify register BPLCON0 in various ways.

### block *x*

Sets the upper nibble of BPLCON0 to values from 0 and 15 with varying values for the HAM bit and the dual-playfield bit. 

### block *x* m

Same as block*x* with an additional manual write to BPL5DAT and BPL6DAT.

### mode *x*

Similar to block*x* with different bitmap patterns and colors.

### mode *x* b

Same as mode*x* with an additional manual write to BPL5DAT.

### mode *x* c

Same as mode*x* with additional manual writes to BPL5DAT and BPL6DAT.

### invprio *x*

Same as mode*x*c with an invalid value for bitplane priority 2 and different bitplane data.

### invplanes1

Switches on 7 bitplanes (invalid value) and manually writes to BPL5DAT and BPL6DAT.

### hilo

Switches between hires and lores mode inside the last fetch unit.


Dirk Hoffmann, 2019 - 2022
