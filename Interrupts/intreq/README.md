## Objective

Test multiple aspects of register INTREQ.

#### intreqcia0

The CPU constantly reads INTREQ and sets the background color accordingy. The Copper it utilized to trigger interrupts. The interrupt handlers perform certain CIA actions.

#### intreqcia1 - intreqcia5

At the beginning of each frame, timers CIAA::A and CIAB::A are startet to set the corresponding bit in the ICR register. CIA interrupts are enables inside the CIAs, but disabled in INTENA. After the timers have terminated, the test cases try to modify the INTREQ bits by writing into INTREQ, ICR, or both. The resulting contents of INTREQ in display by color bars in the test image. 

intreqcia1 clears the IRQ bits in INTREQ only. intreqcia2 clears the IRQ bits in ICR only. intreqcia3 clears the IRQ bits in both INTREQ and ICR only (INTREQ is cleared first). intreqcia4 clears the IRQ bits in both INTREQ and ICR only (ICR is cleared first). intreqcia4 enables CIAA IRQs and clears both INTREQ and ICR in the interrupt handler (note: the IRQ is retriggered once, because INTREQ is cleared before ICR).


Dirk Hoffmann, 2020
