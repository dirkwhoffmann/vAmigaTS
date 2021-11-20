## Objective

This test modifies the horizontal components of DIWSTRT and DIWSTOP.

### Color section 1

DIWSTRT and DIWSTOP are incremented and decremented by the smalles possible delta values.

### Color section 2

DIWSTRT and DIWSTOP are set to their min and max values ($00 and $FF in all four combinations).

### Color section 3

DISSTRT and DIWSTOP are modifie around the first and last DMA cycle where the register value has an effect on Denise. More precisely: If DIWSTRT is too small or DIWSTOP too large, their value is ignored, because the comparator circuit is not active in this range. 

### Color section 4

DISSTRT and DIWSTOP are put as close together as possible.




