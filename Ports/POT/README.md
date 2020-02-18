## Summary

#### pot0dat0

Starts potentiometer measurement in the VSYNC handler and steadily compares the upper 8 bits of VHPOSR (plus 8) with the upper 8 bits of POT0DAT. If both values match, backgroud color is switched to green. Otherwise, it is switched to red. 

#### pot0dat1

Visualizes POT0DAT (without modifying POTGO before).

#### pot0dat2 - pot0dat6

Starts potentiometer measurement by setting the START bit in POTGO. Utilizes the Copper to read back POT0DAT in different lines.

#### potgo1

Visualizes POTGOR (without modifying POTGO before).

#### potgo2 - potgo5

Writes different value combinations into POTGO and visualizes POTGOR afterwards.


Dirk Hoffmann, 2020