## Objective

Verifies basic properties of the memory management unit.

#### mmureg1, mmureg2

A very basic test for verifying the MMU registers. Some constant values are written into MMUSR, TT0, TT1, CRP, and SRP. The values are read back and displayed on the screen. mmureg1 utilizes the PMOVE command, mmureg2 utilizes PMOVEFD.

#### ptest30r, ptest30w

These tests verifiy the ACU (Access Control Unit) of the 680EC030. Both tests write various values into TT0 (aka AC0). After that, ptest30r issues a PTESTR instruction and ptest30w issues a PTESTW instructions. After each PTEST call, the value of the ACSR (aka MMUSR) is recorded and displayed.


Dirk Hoffmann, 2022
