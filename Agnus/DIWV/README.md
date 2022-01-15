## Objective

Test the vertical position components in DIWSTRT and DIWSTOP. 

#### diwv1, diwv2

Standard test cases with common start and stop values.

#### diwv3, diwv4

DIWSTRT starts early (line 0 and 1, respectively). 

#### diwv5, diwv6, diwv7

DIWSTRT and DIWSTOP are close together. DIWSTRT starts one line earlier than DIWSTOP in diw5, in the same line in diw6, one line later in diw7.

#### diwv8

DDFSTOP is never hit.

#### diwv9

DDFSTRT is set in the same line where it hits. It is set mid-scanline.

#### diw10 - diw15

DDFSTRT is set in the same line where it hits. It is set close to the DDFSTRT position.

#### onoff1

Modifies DIWVSTRT and DIWSTOP in the middle of some scanlines. The comparison value will start or stop matching the current vertical position.


Dirk Hoffmann, 2022
