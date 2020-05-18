## Objective

To test counters in CNT pin counting mode.

#### cnt1 

Timer CIAB::A is configured to count rising edges on the CNT pin. The edges are created manually by writing $00, $FF, $00, $FF, ... into CIAB::PRA (Note: Bit CIAB::PA1 is connected to the CNT pin). To visualize the result, the current counter value is written into the background color register.

#### cnt2

Similar to cnt1 for CIAB::B. 

#### cnt3

Counter CIAB::A is driven by the system clock. Counter CIAB::B is driven by underflows of timer A.

#### cnt4

Counter CIAB::A is driven by the CNT pin as in cnt1. Counter CIAB::B is driven by underflows of timer A.

#### cnt5

Counter CIAB::A is driven by the system clock. Counter CIAB::B is driven by underflows of timer A in combination with the CNT = 1 condition. CNT is set to 1 in this case. 

#### cnt6

Same as cnt5 with CNT = 0 all the time. 


Dirk Hoffmann, 2020
