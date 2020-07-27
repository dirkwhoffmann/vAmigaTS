## Objective

Displays the initial values of the CIA registers.

#### ciainit0 to ciainit15

Each test reads the value of a certain CIA register (0 to 15) from both CIAs and visualizes the result in form of color bars. The tests have been written to retrieve information about the initial values of uninitialized CIA registers. Note that some (but not all) CIA registers get initialized before the test case runs. Hence, we don't always see the real uninitialized value.


Dirk Hoffmann, 2020
