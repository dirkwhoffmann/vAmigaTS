## Objective

Test the vertical position components in DIWSTRT and DIWSTOP. 

#### diwv1, diwv2

Standard test cases with common start and stop values.

#### diwv3, diwv4

DIWSTRT starts early (line 0 and 1, respectively). 

#### diwv5, diwv6, diwv7

DIWSTRT and DIWSTOP are close together. DIWSTRT starts one line earlier than DIWSTOP in diw5, in the same line in diw6, one line later in diw7.

#### diwv8

DIWSTOP is never hit.

#### diwv9

DIWSTRT is set in the same line where it hits. It is set mid-scanline.

#### diw10 - diw15

DIWSTRT is set in the same line where it hits. It is set close to the DDFSTRT position.

#### diw16 - diw17

This test uses a DIW that only spans the upper half of the screen. In the lower half, BPL0DAT and BPL1DAT are written directly by the Copper. The test shows that video output can be generated in the vertical border area. 

#### onoff1

Modifies DIWVSTRT and DIWSTOP in the middle of some scanlines. The comparison value will start or stop matching the current vertical position.


Dirk Hoffmann, 2022
