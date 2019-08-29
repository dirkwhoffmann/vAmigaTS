## Objective

Verification of basic properties of the disk  related CIA registers (CIAA::PRA and CIAB::PRB).

#### disk1

This test visualizes the contents of CIAA::PRA in color registers COLOR00 and COLOR01. By pressing the fire button in port 1 or port 2, drive df0: or df1: can be selected by clearing the corresponding SELx bit in CIAB::PRB. 

There is no reference picture for this test, because it is supposed to test action sequences such as "Insert disk in df1:, select df0:, deselect df0:, select df1:, ...".


Dirk Hoffmann, 2019