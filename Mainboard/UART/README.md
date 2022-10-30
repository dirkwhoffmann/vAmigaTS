## Objective

Test basic UART porperties.


#### tbeirq1 - tbeirq6

The Copper is utilized to trigger level 2 - 6 interrupts. In the interrupt handler, the CPU writes to SERDAT which is going to trigger a level 1 interrupt. In the level 1 interrupt handler, SERDAT is written a second time. Timing is visuialized in form of color stripes.


#### tsre1 - tbtsre9

The Copper is utilized to trigger level 2 - 6 interrupts. In the interrupt handler, the CPU writes to SERDAT which is going to trigger a level 1 interrupt. The CPU waits until the corresponding interrupt bit is set and changes the background color afterwards.


#### txirq0 

The Copper is utilized to write into SERDAT. The background color is changed in the interrupt handler.


#### txirq1 - txirq5

More sophisticated variants of txirq0. The Copper is utilized to write SERDAT two times in a row at various positions. In some cases, the second write is performed before the TBE interrupt occurs. 


Dirk Hoffmann, 2022
