## Summary

#### cmp0hi, cmp0lo, cmp1hi, cmp1lo

Compares POTxDAT with the current vpos. If VPOS - 8 == POTxDAT, the background color is changed to green. Otherwise, it is changed to red.

#### pot0dat1

Visualizes POT0DAT with color bars.

#### pot0dat2 - pot0dat6

Starts potentiometer measurement by setting the START bit in POTGO. Utilizes the Copper to read back POT0DAT in different lines.

#### pot1dat1

Visualizes POT1DAT (without modifying POTGO before).

#### potgo0

Visualizes POTGOR (without modifying POTGO before).

#### potgo1 - potgo8

Writes different value combinations into POTGO and visualizes POTGOR afterwards.

#### potout 

Tests various POTGO combinations with some bits configured as outputs.


Dirk Hoffmann, 2020