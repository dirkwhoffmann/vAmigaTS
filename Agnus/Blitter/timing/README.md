## Objective

Test Blitter interrupt timing

#### timing0 - timing15

These tests run the Blitter with various combinations for the channel bits, the fill bit, and the line mode bit. The Copper is utilized to change the background color and start the Blitter. Once the Copper reveives the termination signal from the Blitter, it changes the background color back to black.

#### timingXXl1, timingXXl3, timingXXl4

These tests are special because they run the line Blitter with an unsual width of 1, 3, or 4, respectively. Since a value other than 2 screws up the internal Blitter logic, hardly any real-life program will use such values. Hence, the tests are not really important and will fail in vAmiga. 

Dirk Hoffmann, 2021