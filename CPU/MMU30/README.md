## Objective

Verifies basic properties of the memory management unit.

#### 30avail*x*

Very simple tests to check if certain MMU instructions are available. The tests execute various instructions from the 68030 instruction set. If the instructions are available, green bars appears on the screen. Otherwise, the instructions will trigger a Line-F instruction and the bars appear in red.

The following instructions are tested:

- 30avail1: PFLUSH, PFLUSHA 
- 30avail2: PLOADR, PLOADW
- 30avail3: PTESTR, PTESTW
- 30avail4: PMOVE MEM -> MMU
- 30avail5: PMOVE MMU -> MEM

#### 30ECptestr, 30ECptestw

These tests verifiy the ACU (Access Control Unit) of the 680EC030. Both tests write various values into TT0 (aka AC0). After that, ptest30r issues a PTESTR instruction and ptest30w issues a PTESTW instructions. After each PTEST call, the value of the ACSR (aka MMUSR) is recorded and displayed.

#### 30invalid*x*

These tests integrate an invalid table descriptor into the table structure. Accessing such a descriptor causes a bus error exception. In the exception handler, some stack information is recorded and displayed on the screen afterwards.

#### 30invalid*x*_rte

Similar to 30invalid*x* with a different method to exit the bus error handler. Whereas 30invalid*x* uses a direct jump, these tests exit the handler with the RTE instruction. Before leaving the handler, the cache is flushed and the invalid descriptor removed from the table to prevent another bus error to happen. 

#### 30limit*x*

Triggers a bus error due to a index limit violation. 30limit1 and 30limit2 violate the limit by setting a lower and a upper limit in a table descriptor, respectively. 30limit3 adds a limit to the CRP.

#### 30reg1, 30reg2

Very basic tests to verify data transfer to and from the MMU registers. Some constant values are written into MMUSR, TC, TT0, TT1, CRP, and SRP. The values are read back and displayed on the screen. mmureg1 utilizes the PMOVE command, mmureg2 utilizes PMOVEFD.

#### 30supervisor1

This test accesses a supervisor-secured memory area with the supervisor bit unset.

#### 30translate1

This test checks the 68030 MMU with a very simple page table. It maps range $Axxxxx to $Dxxxxx and utilizes a 1:1 mapping for all other regions. After enabling the MMU, the test modifies the background color
by accessing the color register via the $Axxxxx mirror space. If the MMU works as expected, the background color appears green.

#### 30translate2, translate3, translate4

Similar to translate1 with more sophisticated table structures. 

#### 30translate5

Same as translate4 with an additional indirect descriptor at the bottom of the table. 

#### 30translate6

Same as translate4 with TID = 0 which makes the pointer to table D an indirect descriptor. 

#### 30translate7

Same as translate1 with another layer of indirection (FC bit set).

#### 30translate*i*l

Same as translate*i* with long table entries instead of short table entries.

#### 30ubit1, 30ubit1l, 30ubit2, 30ubit2l

This test performs some memory accesses and dumps portions of the MMU table afterwards. It verifies that the U bit is set for all used table entries. 

#### 30ubit3, 30ubit13

This test performs some memory accesses and dumps some page descriptors afterwards. It verifies the values of the U bit and the M bit.

#### 30wp*x*, 30wp*x*l, 30wp*x*_rte

Triggers a bus error by writing into a write-secured memory area. 


Dirk Hoffmann, 2022
