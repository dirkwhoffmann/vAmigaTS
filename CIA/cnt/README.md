## Objective

To test counters in CNT pin counting mode.

#### cnt1 

Timer CIAB::A is configured to count rising edges on the CNT pin. The edges are created manually by writing $00, $02, $00, $02, ... into CIAB::PRA (Note: Bit CIAB::PA1 is connected to the CNT pin). To visualize the result, the current counter value is written into the background color register.

#### cnt2

Similar to cnt1, but the background color is changed to yellow in the CIAB interrupt handler. 

#### cnt3 and cnt4

Same as cnt1 and cnt2 for timer CIAB::B.


Dirk Hoffmann, 2020
