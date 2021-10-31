## Objective

Test Blitter timing

#### cputim1 - cputim7

These tests run the Blitter with various combinations for the channel bits, the fill bit, and the line mode bit. The Copper is utilized to trigger interrupts. Inside the interrupt handler, the Blitter is started by the CPU. The Copper waits for the Blitter and changes the background color when the Blitter has terminated. 


#### invisible0 - invisible15

These tests run the Blitter with various combinations for the channel bits, the fill bit, and the line mode bit. The Copper is utilized to both start the Blitter and to observe when the Blitter has finished. The CPU interferes by executing a loop that changes the background color periodically. 


Dirk Hoffmann, 2021