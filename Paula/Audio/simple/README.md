## Summary
---

### dmaaud1

Plays a sine wave on channel 0 via audio DMA. After 2 seconds, audio DMA is disabled. Yellow color stripes visualize the invocations of the level 4 interrupt handler.

### dmaaud2

Similar to dmaaud1, but the IRQ is continued to be acknowledged after DMA has been turned off. This continues to drive audio playback in IRQ based mode. The frequency changes, because no samples are fed into AUD0DAT any more.

### dmaonoff1

Enables audio DMA by the Copper, reads in a DMA word and disables DMA one line later.

### dmaonoff2

Enables audio DMA by the Copper, reads in a DMA word and disables DMA two lines later.

### pertimer1

A variation of the program listed at the end of this thread: 
https://eab.abime.net/showthread.php?t=54961


---
Dirk Hoffmann, 2020
