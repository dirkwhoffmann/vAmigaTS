## Objective

This test suite verfies properties of the DMACON register

#### bplen1 and bplen2

These tests toggle the BPLEN bit at various DMA cycle positions.
Make sure to select "OCS Chipset" in SAE to reproduce the reference image. The ECS chipset behaves differently, i.e., when switching DMA on in the middle of the rasterline. 

#### bplen3 and bplen4

These tests were written to validate the following property about the OCS chipset: If bitplane DMA is switched on, the current rasterline is only affected if the electron beam hasn't reached the DDF start position yet. Once the start position is crossed with bitplane DMA disabled, DMA can no longer switched on in this rasterline. The ECS chipset is different. Therefore, make sure to select the correct chipset before running this test in SAE or UAE. 

#### bplen5

This test backs up the following: When the electron beam crosses the DDF boundary and DMA was on, it can be switched on and off multiple times in that rasterline. 

#### bplon*x*

These tests utilize the Copper to enable bitplane DMA in the middle of a rasterline.

#### bplon*x*h

Same as bplon*x* in hires mode. 


Dirk Hoffmann, 2019 - 2020
