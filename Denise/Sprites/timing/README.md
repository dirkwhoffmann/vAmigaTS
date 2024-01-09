## Objective

The tests in this directory verifiy timing of sprite related registers.

### oldsprtimdat, oldsprtimpos (DEPRECATED)

These tests draw a number of sprites and utilize the Copper to change SPRxDATA, SPRxDATB, and SPRxPOS manually at positions close to the horizontal sprite start. Both tests are first-generation tests and have been deprecated. Although they have been replaced by better ones (sprtimdat1, sprtimpos1, ...) I kept them for the time being.

### sprtimdat1, sprtimdat2

Improved versions of oldsprtimdat. The tests incorporate the case of odd horizontal sprite positions.

### sprdmadat1, sprdmadat2

Similar to sprtimdat, but the registeres are written close to the DMA cycles.

### sprtimpos1

Improved version of oldsprtimpos. The test displays 8 sprites via standard sprite DMA. The Copper is utilized to write into SPRxPOS at positions close to the horizonzal sprite start. When the write happens early enough, the sprite is shifted to the right in the correspnding line.

### sprtimctl1

Similar to sprtimpos1 for the SPRxCTL register. 

### sprxpos

This test has been provided by GitHub user mras0 to reveal the root cause of vAmiga issue #750 (Elfmania). It tests a timing aspect similar to sprtimpos1. 


Dirk Hoffmann, 2022
