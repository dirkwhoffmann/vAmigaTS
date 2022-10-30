## Objective

Verifies special aspects of the Blitter

#### barrel1

This test verifies the behaviour of the barrel shifters and utilizes the special "channel B feature". Background: When BLTBDAT is written, the barrel shifter on data path B is run. This can be used to put a special value into BHOLD which will then be used in the next blit if channel B is disabled. Note that writing BLTBDAT also modifies the internal BOLD register which means that writing BLTBDAT a second time can alter BHOLD again. Channel A doesn't exhibit this feature. I.e., the barrel shifter on data path A is always run, even if channel A is disabled. 

Dirk Hoffmann, 2021
