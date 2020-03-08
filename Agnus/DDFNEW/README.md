## Objective

Modify DDFSTART and DDSTOP in various ways. Note that the result differes between OCS Agnus and ECS Agnus. The old OCS Agnus ignores bit H1 in both DDFSTRT and DDFSTOP. 

#### ddfnew1 - ddfnew10

These tests set DDFSTART and DDFSTOP to different combinations inside the valid range. The upper part of the screen is drawn in lores mode and the lower part in hires mode.

#### farright1

Sets DDFSTOP to very high coordinates.

#### shift1

Uses DDFSTART and DDFSTOP in combination with BPLCON1. This test has been written to hunt down the vAmiga "Siedler bug".


Dirk Hoffmann, 2020
