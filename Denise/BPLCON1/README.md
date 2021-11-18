## Objective

The tests in this test suite modify register BPLCON1 (biplane shift values) in various ways.

## New tests

#### simple<n> 

Sets DDFSTRT to $38 + n and runs BPLCON1 through $00, $11, $22, etc.

#### timing1 - timing5

Modifies BPLCON1 at a various positions in the middle of a rasterline.


Dirk Hoffmann, 2019 - 2021
