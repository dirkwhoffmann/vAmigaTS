## Summary
---

### custC

This test scans  memory area $C00000 - $CFFFFF for chipset  mirrors by writing a value at address $xxx180. If a mirrored chipset address is found, the background color toggles between yellow and black. 

### custD, custE

Same for memory ranges $D00000 - $DFFFFF and $E00000 - $EFFFFF.

### kickmirror

This tests searches for kickstart mirrors in the 16 memory pages $C0, $C4, $C8, ..., $FC and visualizes the result in form of color bars. A white bar indicates that a match has been found.

---
Dirk Hoffmann, 2020
