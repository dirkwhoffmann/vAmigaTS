## Summary
---

### diwtim1 - diwtim4

These test utilize the Copper to modify DIWSTRT and DIWSTOP at locations close to the old trigger coordinate. 


### diwtim1b - diwtim4b

These test utilize the Copper to write trigger coordinates into DIWSTRT and DIWSTOP that are close to the current location. 

### minmax 

This test was mentioned in vAmiga GitHub issue 710. It sets DIWSTRT and DIWSTOP to very small and very high values, respectively. It can be used to determine the smallest and largest meaningful coordinate.

### minmax2

A rectified and slightly enhanced variant of the minmax test.

### minmax3

This test is related to vAmiga GitHub issue #799. Background: The last possible DIW stop is position $1c7, because the DIW counter runs through the sequence $1c6, $1c7, 2, 3, etc.. As a result, values larger than $1c7 will not trigger the DIW logic, thus producing an overscan line. On ECS Denise and Lisa, this can be worked around, because the uppermost stop bit can be modified via DIWHIGH. Therefore, it is possible to use values such as 2, 3, ... as trigger coordinates. This trick is impossible on OCS machines since the uppermost stop bit for the DIW window is hard-coded to 1. This test case exploits the trick and produces a different image if an ECS Denise or Lisa chip is plugged in. 

---
Dirk Hoffmann, 2022 - 2023
