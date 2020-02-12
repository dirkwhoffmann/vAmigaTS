## Summary
---

### dmamod *n*

Combines DMA driven audio with channel modulation.

- dmamod1

  Channel 0 modulates the volume of channel 1.

- dmamod2

  Channel 0 modulates the period of channel 1.

- dmamod3

  Channel 0 modulates both volume and period of channel 1.

- dmamod4

  Like dmamod3 with screwed up modulation data. Data contains an odd number of data words which causes volume and period information exchanged in every second run. As a result, audio will be almost silent in every second run.


### irqmod *n*

Combines IRQ driven audio with channel modulation.

- irqmod1

  Channel 0 modulates the volume of channel 1.

- irqmod2

  Channel 0 modulates the period of channel 1.

- irqmod3

  Channel 0 modulates both volume and period of channel 1.

- irqmod4

  Like irqmod3 with screwed up modulation data.

---
Dirk Hoffmann, 2020
