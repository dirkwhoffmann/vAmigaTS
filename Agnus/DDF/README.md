## Objective

The DDF tests use the Copper to modify DDFSTART and DDSTOP in various ways.

#### ddf1

DDFSTRT is incremented continously at the end of certain rasterlines. DDFSTOP is aligned at $D0 and not changing.

#### ddf1b

DDFSTRT is incremented continously at the beginning of certain rasterlines. DDFSTOP is aligned at $D0 and not changing.

#### ddf1m

DDFSTRT is incremented continously at the end of certain rasterlines. DDFSTOP is misaligned at $D3 and not changing.

#### ddf2 

DDFSTRT is aligned at $38 and not changing. DDFSTOP is incremented continously. 

#### ddf2m 

DDFSTRT is misaligned at $3B and not changing. DDFSTOP is incremented continously. 

#### ddf3

DDFSTRT is decremented continously. DDFSTOP is aligned at $D0 and not changing.

#### ddf3m

DDFSTRT is decremented continously. DDFSTOP is misaligned at $D3 and not changing.

#### ddf4

DDFSTRT is aligned at $38 and not changing. DDFSTOP is decremented continously. 

#### ddf4m

DDFSTRT is misaligned at $3B and not changing. DDFSTOP is decremented continously. 

#### ddf5

Various combinations of DIWSTRT and DIWSTOP. Some combinations cross the hardware stop boundaries.

#### ddf6

Mores test combinations around the hardware stops.

#### ddf7

Modifying DDFSTRT and DDFSTOP around the specified start and specfied stop positions.

Dirk Hoffmann, 2019