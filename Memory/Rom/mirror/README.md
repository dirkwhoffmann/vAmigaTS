## Summary
---

### customC1, customC2, customD1, customD2, customE1, customE2

Half a megabyte per test, one address per raster line. The *n*-th line of the band writes a colour to `$XYY180`, the address COLOR00 would occupy if the register block were mirrored at `$XYY000`, stepping `$1000` per line from the test's start address.

```
customC1   $C00000 - $C7FFFF      customC2   $C80000 - $CFFFFF
customD1   $D00000 - $D7FFFF      customD2   $D80000 - $DFFFFF
customE1   $E00000 - $E7FFFF      customE2   $E80000 - $EFFFFF
```

**Yellow line** — the write reached COLOR00, so that address is a mirror.
**Black line** — it did not.

The 128 lines are split into eight blocks of sixteen, ruled off by white Copper lines, so a line's number is read as "block times sixteen plus offset" rather than counted from the top. The top rule is two lines tall and every other rule is one, which is the only asymmetry in the picture: a photograph cropped at one end still shows which end it lost.

The rules are safe from the probe. A rule line carries no probe, so nothing raises an interrupt on the line before it and no CPU write can land on one. That matters: `customD1` is a solid yellow slab from top to bottom, and without the rules there would be nothing in it to count against.

The band spans raster lines `$4B` to `$D4`, centred inside the `$2C` to `$F4` window every PAL monitor shows.

#### Why these replace custC, custD and custE

The older tests drive the probe from a CPU loop, and the picture encodes how long that loop took: where a line changes colour records one particular CPU speed and one particular pattern of bus arbitration. The reference images are therefore recordings of a machine rather than statements about the memory map, and no two machines agree on them. All three still fail in vAmiga today, as does kickmirror.

Here the Copper owns every visible transition and the CPU owns none:

```
HP $E0 of the previous line   Copper raises a level 1 interrupt
HP $00 of this line           Copper resets COLOR00 to black
HP $1A or thereabouts         the interrupt handler writes the probe
HP $31 onwards                the part of the line a screenshot records
```

The handler's single write is the only event whose position depends on the CPU, and it is aimed at the gap between the end of one line and HP $31 of the next — 49 colour clocks, just under a hundred 68000 cycles, against an interrupt latency of roughly 44 plus a three instruction handler. There is no CPU synchronisation code at all.

#### What was measured

Running customD2 on four machine configurations, including an A1200 whose 68EC020 has an entirely different interrupt latency:

| configuration | non-uniform lines | rules intact | mirror map (probe numbers) |
|---|---|---|---|
| A500 OCS 1MB | 0 of 128 | 10 of 10 | mirror 0-63, none 64-95, mirror 96-127 |
| A500 ECS 1MB | 0 of 128 | 10 of 10 | mirror 0-63, none 64-95, mirror 96-127 |
| A500+ 1MB | 0 of 128 | 10 of 10 | mirror 0-63, none 64-95, mirror 96-127 |
| A1200 2MB | 0 of 128 | 10 of 10 | mirror 0-63, none 64-95, mirror 96-127 |

"Non-uniform" counts lines carrying more than one colour across the recorded width, which is what a probe landing inside the visible area would produce. Every line is flat on every configuration and the four maps agree exactly. Repeated runs are byte identical.

The vAmiga map, read off all six references: `$C00000-$C7FFFF` is slow RAM and answers no; `$C80000-$DBFFFF` and `$DE0000-$DFFFFF` are mirrors; `$DC0000-$DDFFFF` is the real time clock rather than a mirror; nothing in `$E00000-$EFFFFF` answers at all.

#### Two things the layout is working around

**Raster line 0 is not on the monitor.** A first revision put all 256 probes of a megabyte on one screen, which made the band run from line `$1E` to `$11D` — inside vAmiga's 285 line capture, but cropped at both ends by a real display. Halving the band to 128 lines and doubling the number of tests puts the whole thing in the safe window.

**The Copper's vertical counter is eight bits wide.** The 256 line band also crossed raster line 256, where a wait for a low line number falls through instead of waiting. The usual `$FFDF,$FFFE` idiom does not help, because by the time it is reached the beam is already past HP $DE: it either falls through as well or, if the counter has just wrapped, waits for a line that will not come again until the next frame — which is what it did, freezing the picture from line 256 down. The 128 line band ends at line `$D4` and never meets the problem; `custom.i` fails at assembly time if a change pushes it past line 255.

### kickmirror

This tests searches for kickstart mirrors in the 16 memory pages $C0, $C4, $C8, ..., $FC and visualizes the result in form of color bars. A white bar indicates that a match has been found.

---
Dirk Hoffmann, 2020
