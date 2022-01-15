## Objective

Verifies the emulation of the display window (DIW). The tests are marked as OLD, because I wrote them very early in the development of vAmiga. They are not optimal, because they both modify the horizontal and vertical coordinates in DIWSTRT and DIWSTOP. However, both coordinates should be treated seperately, because the vertical coordinate is handled solely by Agnus whereas the horizontal coordinate is handled solely by Denise. 

#### diw1 - diw11

These tests utilize the Copper to manipulate DIWSTRT and DIWSTOP in various ways.

#### diwvert1

DEPRECATED. Superseded by DIWV/onoff1


Dirk Hoffmann, 2019 - 2022
