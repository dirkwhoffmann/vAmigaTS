## Objective

Most tests are basic CPU instruction tests that were written before I disconvered UAE's awesome cputester framework. Now the tests are obsolete and no longer maintained.

#### guru

This is a test that was screwed up by accident. At the end of the IRQ handler, there is a 

    movem.l    (sp)+,d0-a6

instruction, but no corresponding instruction at the beginning. As a result, the computer eventually issues an address error exception which causes the RESET instruction to executed. As a result, the machine reboots and displays a guru. 

I kept the test to verify the RESET instruction in vAmiga. 


Dirk Hoffmann, 2020
