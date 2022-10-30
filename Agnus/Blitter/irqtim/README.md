## Objective

Test Blitter interrupt timing

#### irqtim0 - irqtim15

These tests run the Blitter with various combinations for the channel bits, the fill bit, and the line mode bit. The Copper is utilized to change the background color and start the Blitter. The background color is changed back in the Blitter IRQ handler.

#### irqtimXXl1, irqtimXXl3, irqtimXXl4

These tests are special because they run the line Blitter with an unsual width of 1, 3, or 4, respectively. Since a value other than 2 screws up the internal Blitter logic, hardly any real-life program will use such values. Hence, the tests are not really important and will fail in vAmiga. 


Dirk Hoffmann, 2021