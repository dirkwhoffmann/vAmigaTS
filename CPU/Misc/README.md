#### prefetch*n*

The tests in this suite utilize self-modifying code to draw several color bars. The colors indicate if the prefetch cycle of an instruction is executed before or after the operand write cycle. 

For detailed information about the prefetch queue see here:
http://pasti.fxatari.com/68kdocs/68kPrefetch.html

#### timing1

This test syncs the CPU in the middle of each frame (magenta area). The CPU is run in a color loop that draws a grey shaded pattern. Bitplane DMA is off all the time and the Copper stopped.

#### timing2

Same as timing1 with a modified color loop.

#### timing3 

Same as timing2 with 4 lores bitplanes and the Copper enabled.

#### timing4 

Same as timing2 with 5 lores bitplanes and the Copper enabled.

#### timing5 

Same as timing2 with 6 lores bitplanes and the Copper enabled.

#### timing6 

Same as timing2 with 3 hires bitplanes and the Copper enabled.

#### timing7

Same as timing2 with 4 hires bitplanes and the Copper enabled.

#### trace1 to trace6

Each tests triggers a level 1 interrupt which executes the test code. Inside the interrupt handler, the trace flag is manipulated in various ways and the resulting program flow is visualized by color bars.


Dirk Hoffmann, 2019 - 2022
