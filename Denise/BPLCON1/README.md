## Objective

The tests in this test suite modify register BPLCON1 (biplane shift values) in various ways.

#### simple<n> 

Sets DDFSTRT to $38 + n and runs BPLCON1 through $00, $11, $22, etc.

#### timing1 - timing5

Modifies BPLCON1 at a various positions in the middle of a rasterline.

#### overscan1 - overscan6

Increases BPLCON1 one by one at high DMA cycles. 

#### overscan1b - overscan6b

Decreases BPLCON1 one by one at high DMA cycles. 


Dirk Hoffmann, 2019 - 2021
