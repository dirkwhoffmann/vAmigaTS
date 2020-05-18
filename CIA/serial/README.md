## Objective

Tests the serial shift register

#### serial1

This test exploits the fact, that the Amiga allows to use the PA port of CIAB to drive the CNT pin and the SP pin of the same CIA. The configures the SP pin as input and generates pulses on the CNT pin by writing into PA. After eight pulses, the contents of the ICR register and the contents of the SDR register are visualized in form of color bars.


Dirk Hoffmann, 2020
