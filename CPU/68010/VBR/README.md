#### VBR1, VBR2

Test VBR1 triggers some interrupts with different values in the vector base register (VBR). VBR2 is similar to VBL1 with an additional offset of $2. It shows that the vector area must not be aligned at a 1KB boundary although the 68010 spec indicates so. A red screen is displayed if a 68000 CPU is detected.


Dirk Hoffmann, 2022
