## Objective

The DDF tests use the Copper to modify DDFSTART and DDSTOP in various ways.

#### ddf1

DDFSTRT is incremented continously. DDFSTOP is aligned at $D0 and not changing.

#### ddf1m

DDFSTRT is incremented continously. DDFSTOP is misaligned at $D3 and not changing.

#### ddf2 

DDFSTRT is aligned at $38 and not changing. DDFSTOP is incremented continously. 

#### ddf2m 

DDFSTRT is misaligned at $3B and not changing. DDFSTOP is incremented continously. 

#### ddf3

DDFSTRT is decremented continously. DDFSTOP is aligned at $D0 and not changing.

#### ddf3m

DDFSTRT is decremented continously. DDFSTOP is misaligned at $D3 and not changing.

### ddf4

DDFSTRT is aligned at $38 and not changing. DDFSTOP is decremented continously. 

### ddf4m

DDFSTRT is misaligned at $3B and not changing. DDFSTOP is decremented continously. 


Dirk Hoffmann, 2019