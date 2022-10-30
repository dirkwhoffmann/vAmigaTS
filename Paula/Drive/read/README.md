## Objective

These tests perform basic disk DMA and check the timing of the DSKBLK interrupt.

#### read1

The Copper is utilized to trigger a couple of interrupts. In the interrupt handler, the disk controller is requested to read in 0 bytes via DMA. The execution of the DSKBLK interrupt handler is visualized in form of a color stripe.

#### read2

Same as read1 in SYNC mode.

#### read3 

Requests 2 words to read with no drive selected. On a real machine (A500 8A with a Gotek drive), the image flickers heavily, meaning that interrupt timing varies between frames. 

#### read4 

Requests 2 words from df0 with the motor off.

#### read5 

Requests 48 words from df0 with the motor on.

#### read6

Requests 48 words from df0 with the motor off.

#### read7 

Requests 48 words with no drive selected and the motor (df0) on.

#### read8

Requests 48 words with no drive selected and the motor off.


Dirk Hoffmann, 2019 - 2020
