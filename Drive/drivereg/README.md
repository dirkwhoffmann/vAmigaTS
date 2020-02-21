## Objective

To test the drive related CIA registers.

#### drivereg1 and drivereg2

On startup, both tests write $FF into CIAB::PRB and display the written value in the lower half. The upper half shows the current contents of CIAA::PRA. By pressing a key, the written value can be changed manually. 

- drivereg1

  Press a number key (*0* .. *7*) to toggle a specific bit.

- drivereg2

  Press *+* or *-* to increment or decrement the written value by 1. 


Dirk Hoffmann, 2020
