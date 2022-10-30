## Objective

Tests some timing aspects of the CIA 24-bit-counter (TOD clock).


#### todcntA1

This test resets the TOD clock of CIA A inside the VERTB IRQ handler. After that, it wait until the TODLO register changes, and display the value of VHPOSR in form of color bars. For the the lower byte (horizontal position), an avarage is computed, because the CIAs don't run in sync with the CPU. Hence, the read back value is not stable. 

#### todintA1

This test resets the TOD clock of CIA A inside the VERTB IRQ handler and sets a TOD alarm. In the TOD interrupt handler, the value of VHPOSR is read and displayed in form of color bars. For the the lower byte (horizontal position), an avarage is computed, because the CIAs don't run in sync with the CPU. Hence, the read back value is not stable. 

#### todcntB1 and todintB1

Same for CIA B.


Dirk Hoffmann, 2020
