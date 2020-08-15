## Overview

The tests in this suite run the Blitter with different input configurations. They don't produce useful output, so it doesn't make sense to run on the real machine. They have been designed to compare different emulators by comparing their debug outputs.

#### minterms1

Runs the Copy Blitter (ascending).

#### minterms2

Runs the Copy Blitter (descending).

#### minterms3

Runs the Copy Blitter (ascending, exclusive fill)

#### minterms4

Runs the Copy Blitter (ascending, inclusive fill)

#### minterms5

Runs the Copy Blitter (descending, exclusive fill)

#### minterms6

Runs the Copy Blitter (descending, inclusive fill)

#### minterms7

Runs the Copy Blitter (ascending, inclusive + exclusive fill)

#### minterms*n*b

Same tests with an unusual Blit size (width = 1)

#### consec*n*

Runs several Blits in a row without initializing the Blitter in between.


Dirk Hoffmann, 2020
