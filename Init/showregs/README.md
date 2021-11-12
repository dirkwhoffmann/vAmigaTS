## Objective

Displays the initial values of some CPU registers.

#### showregs

This test case has been written by GitHub user mras0. The ADF contains special code in the bootblock that reads the values of all data and address registers and displays their values on the screen.

It turned out that D5 or D7 still contain their initial values when the bootblock is executed. All other registers get modified (at least by KS 1.3).

The situation seems to be as follows:

- On some machines, the initial bit value (for most bits) is 0.
- On some machines (including my own A500 8A), the initial bit value (for most bits) is 1.
- There is some randomness involved (on my A500, bit 15 in D5 is sometimes 0).

MC68000UM section 5.5 says only PC/SSP and IPL are touched on RESET which means that neither the data registers nor the address registers are initialized by the CPU. Unfortuntely, some ill-coded demos rely on the initial values of D5 or D7 which means that emulators should put a decent value into those registers on startup. Best compatibility seems to be achieved by a startup value of 0. 

In vAmiga, the initial register value can be customized with option OPT_REG_RESET_VAL. Test showregs1 runs vAmiga with the default setting (OPT_REG_RESET_VAL = 0). Test showregs2 initializes all registers with OPT_REG_RESET_VAL = 0xFFFFFFFF.


Dirk Hoffmann, 2021
