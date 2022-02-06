## Objective

Basic Copper timing tests

#### coptim1 - coptim5

Runs the Copper in areas with multiple bitplanes enabled. 

#### copcpu1

This test runs the CPU through multiple areas with 4, 5, or 6 bitplanes enabled. Inside these areas, the Copper executes multiple WAIT commands to steal bus cycles. 

#### copblt1

Similar idea as copcpu1, but the Copper is utilized to steal cycles from the Blitter. 

#### oldcoptim1

Basic timing with a jump to Copper list 2 involved.

#### oldcoptim2

Designed to bring vAmiga in Copper state COP_REQ_DMA in cycle $E0.

#### oldcoptim3

Designed to bring vAmiga in Copper state COP_WAIT1 in cycle $E0.

#### oldcoptim4 and oldcoptim5

Variants of oldcoptim3


Dirk Hoffmann, 2020 - 2022
