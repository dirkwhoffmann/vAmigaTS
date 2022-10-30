## Objective

To verify head stepping.

#### step1

Moves the drive head inwards to cylinder 100 (which doesn't exist). After that, it moves the head outwards for a fixed number of cylinders to see where the drives gets to rest. My Amiga 500 with a Gotek Drive eventually stops at cyclinder 74. 

#### step2 and step3

Moves the drive head inwards to cylinder 40. After that, the head is moved back to cylinder 0. In the move back phase, the time between head step pulses is reduced to a value that no longer complies to the specs. In step3, the value is still sufficient to move the head in UAE. In step4, it is too short (UAE misses some steps).

#### step4

Pulses the STEP line as fast as possible to see how many cylinders get skipped. 

#### step5

Same as step1 with all four drives selected at the same time. Make sure to connect df0 ... df3 before running this test. The test succeeds if all drives perform the same head movement in parallel.


Dirk Hoffmann, 2020
