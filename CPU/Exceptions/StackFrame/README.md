## Objective

These tests trigger various CPU exceptions and record the resulting stack frames. To reproduce the exact values, make sure to use Kickstart 1.3 and a 512KB+0KB+0KB memory configuration.

**Update:** All address error exception tests have been rewritten. They now use a fixed stack address, making them independent of the installed Kickstart version and memory configuration.


Dirk Hoffmann, 2022 - 2026