## Summary

#### noack1

This test verifies the keyboard behaviour when the Amiga omits to send the acknowledge signal after a keycode has been received. The test reads the contents of CIAA::SDR in the IRQ level 2 handler and displays the result in the upper part of the screen. It also keeps track of how many level 2 IRQs have been issued and displays the counter value in the lower part of the screen. To start the test, hit any key to call the level 2 handler. Because the handler omits to send the acknowledge signal, the keyboard switches to a special state where it tries to resynchronize with the Amiga. In this state, it transmits a one bit every 145 ms which means that the IRQ handler is called again and again with a delay of approx. 1.2 sec. The test case visualizes this: After pressing a key, the upper color bars turn black (because the 1's are received as 0's) and the lower part shows a counting pattern that changes every 1.2 sec. 


Dirk Hoffmann, 2020