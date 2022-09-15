## Objective

Verifies basic properties of the memory management unit.

#### avail*x*

Very simple tests to check if certain MMU instructions are available. The tests execute various instructions from the 68030 and 68040 instruction set. If the instructions are available, green bars appears on the screen. Otherwise, the instructions will trigger a Line-F instruction. In this case, the bars appear in red.

The following instructions are tested:

- avail1: PFLUSH, PFLUSHA (68030)
- avail2: PFLUSH, PFLUSHA, PFLUSHN, PFLUSHAN (68040)
- avail3: PLOADR, PLOADW (68030)
- avail4: PTESTR, PTESTW (68030)
- avail5: PTESTR, PTESTW (68040)
- avail6: PMOVE MEM -> MMU (68040)
- avail7: PMOVE MMU -> MEM (68040)

#### mmureg1, mmureg2

A very basic test for verifying the MMU registers. Some constant values are written into MMUSR, TC, TT0, TT1, CRP, and SRP. The values are read back and displayed on the screen. mmureg1 utilizes the PMOVE command, mmureg2 utilizes PMOVEFD.

#### ptestec30r, ptestec30w

These tests verifiy the ACU (Access Control Unit) of the 680EC030. Both tests write various values into TT0 (aka AC0). After that, ptest30r issues a PTESTR instruction and ptest30w issues a PTESTW instructions. After each PTEST call, the value of the ACSR (aka MMUSR) is recorded and displayed.

#### translate1

This test checks the 68030 MMU. It enables the MMU with a simple 1:1 mapping.

#### translate2

This test checks the 68030 MMU. It maps range $1xxxxxxxxxx to $0xxxxxxxxxx. If the mapping succeeds, green bars appear. 


Dirk Hoffmann, 2022
