## Objective

Verifies basic properties of the MC68040's memory management unit.

#### avail*x*

Very simple tests to check if certain MMU instructions are available. The tests execute various instructions from the 68040 instruction set. If the instructions are available, green bars appears on the screen. Otherwise, the instructions will trigger a Line-F instruction. In this case, the bars appear in red.

The following instructions are tested:

- avail2: PFLUSH, PFLUSHA, PFLUSHN, PFLUSHAN
- avail5: PTESTR, PTESTW

Dirk Hoffmann, 2022
