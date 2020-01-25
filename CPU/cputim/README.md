## Objective

Verification of CPU bus timing

#### cputim1

This test syncs the CPU to a specific horizontal position. After that, it enters a color loop that draws two yellow bars. If the computer freezes with a dark blue or dark red background, the CPU hangs in the sync code.

#### cputim1b

This test contains an experimental sync subroutine that syncs the CPU to a specific raster position. The sync code is drawing in dark red, blue and yellow. The CPU draws in gray. Syncing works if the yellow bar is aligned and the image stable.

#### cputim2

This test verifies CPU bus timing between two frames. At the bottom of the frame, the CPU gets synced first (magenta stripe, size may differ). After that, an interrupt is issued which starts a CPU color loop. The test is run with 4 bitplanes enabled.


Dirk Hoffmann, 2019