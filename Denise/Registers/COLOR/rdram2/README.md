## Objective

Verifies WHEN a colour register write becomes visible to a read. `rdram` establishes that RDRAM makes the registers readable; this asks the follow-up question it deliberately avoided.

`rdram` seeds the registers in one loop and reads them in another, more than a scanline apart, so it cannot distinguish "the register file is updated as the write is issued" from "the register file is updated once per line". On hardware there is nothing to distinguish. In vAmiga colour writes queue in `colChanges` and are replayed once per line (`PixelEngine::colorize`, `replayColRegChanges`), so a read saw the file as it stood at the end of the previous line.

#### The three probes

Every probe uses COLOR01, seeded blue and then written green. The value that comes back paints a band, so each band reads directly:

```
green   the read returned the NEW value
blue    the read returned the OLD value
```

- **Section 1** — write, then read, same line. Hardware returns the new value: green.
- **Section 2** — read, then write, same line. The read must not see a write that has not happened yet: blue, on every machine.
- **Section 3** — write, then read two lines later. The control, saying the readback works at all: green everywhere.

Each section runs its probe at eight horizontal positions and paints one band per position, so a result that depended on where in the line the probe sat would show up as a section that is not one solid colour.

#### What each section is for

Section 1 is the bug. Section 3 stops section 1 being misread as "the readback is broken". Section 2 guards the fix: the repair is to search the recorded colour changes, and the way to get that wrong is to return the newest recorded value rather than the newest one recorded *at or before* the read.

```
machine / state                  sec 1   sec 2   sec 3
A1200                            green   blue    green
vAmiga, readback not searched     blue   blue    green
vAmiga, search ignoring order    green   green   green
vAmiga, correct                  green   blue    green
```

#### Notes on the source

The probes run with DMA off and bitplanes disabled, so nothing competes for cycles. Results are latched into memory and only then patched into the Copper list, so the picture imposes no timing constraints of its own.

`syncLine` watches the line number rather than the horizontal position. Waiting for a small horizontal position instead ("spin until hpos <= 10") looks equivalent and is not: that window is eleven colour clocks wide, one poll of VHPOSR costs more than that, and the loop steps over the window and spins for ever. Whether it lands inside depends on the alignment of the caller.


Dirk Hoffmann, 2026

## Regression testing

Run under `_aga` (A1200_2MB) only. RDRAM is decoded on AGA alone; elsewhere a read returns bus contents and there is nothing to compare.
