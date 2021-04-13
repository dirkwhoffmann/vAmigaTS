## Objective

The tests in this test suite modify register BPLCON1 (biplane shift values) in various ways.

## New tests

#### simple<n> 

Sets DDFSTRT to $38 + n and runs BPLCON1 through $00, $11, $22, etc.

#### simple1 [DEPRECATED]

Modifies BPLCON1 at the beginning of a rasterline. 

#### timing1 - timing5

Modifies BPLCON1 at a various positions in the middle of a rasterline.


## Old tests

#### shift1

Modified BPLCON1 at each red line. The display window (DIW) is opend up as much as possible. 

#### shift1d, shift1h, shift1dh

Same as shift1 in dual-playfield mode, hires mode, or both. 

#### shift2

Same as shift1 and shift1h with simpler values. Even and odd bitplanes are always equal.

Dirk Hoffmann, 2019
