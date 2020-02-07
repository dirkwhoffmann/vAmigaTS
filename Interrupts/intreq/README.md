## Objective

Test multiple aspects of register INTREQ.

#### intreqcia *n*

At the beginning of each frame, timers CIAA::A and CIAB::A are startet to the corresping bit in the ICR register. CIA interrupts are enables inside the CIAs, but disabled in INTENA. After the timers have times out, the test cases try to modify the INTREQ bits by writing into INTREQ, ICR, or both. The resulting contents of INTREQ in display by color bars in the test image. 

##### intreqcia1

Clears the IRQ bits in INTREQ only.

##### intreqcia2

Clears the IRQ bits in ICR only.

##### intreqcia3

Clears the IRQ bits in both INTREQ and ICR only. INTREQ is cleared first.

##### intreqcia4

Clears the IRQ bits in both INTREQ and ICR only. ICR is cleared first.


Dirk Hoffmann, 2020
