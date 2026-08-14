## Objective

The AGA counterpart of the Agnus/DDF/DDF suite. Those tests hold DDFSTRT fixed within a frame, sweep DDFSTOP across the subsections, and draw two sections — one lores, one hires, both with a single bitplane. This suite generalises all three of those axes:

```
three sections instead of two      lores, hires and super hires
eight subsections per section      1, 2, 3 ... 8 bitplanes
two Copper rulers instead of one   one between each pair of sections
```

and lifts **DDFSTRT, DDFSTOP and FMODE** out of the body into the wrapper. `agaddf.i` holds everything else, and `agaddf1.s` ... `agaddf10.s` are three-line files that define the parameters and include it. A single frame therefore answers "where does the bitplane data start and stop" for one (DDFSTRT, DDFSTOP, FMODE) triple across every resolution and every bitplane count the chipset offers.

#### Reading the picture

BRDRBLNK is set for the whole frame apart from the two ruler lines, so the border is forced to pure black, and COLOR00 — the colour of the display window wherever the bitplanes have not delivered data — is dark grey ($444). ECSENA is set throughout, because BRDRBLNK does nothing without it. Every rasterline therefore reads as five zones:

```
black         border, left of DIWSTRT
dark grey   window open, no bitplane data yet
a fine comb   the bitplane data
dark grey   data finished, window still open
black         border, right of DIWSTOP
```

The two inner edges are the measurement. The left one is the first pixel DDFSTRT produces, the right one is the last pixel DDFSTOP allows, and both are read against the Copper rulers.

This is the whole reason for the blanked border. Without it COLOR00 would paint the border as well, the dark grey zones would merge into it, and neither inner edge would be locatable — which is exactly the blind spot that made the same measurement impossible in the bplam test until bplam3 blanked the border to expose it.

#### The bitplane data

All eight bitplanes point at **one** buffer filled with the `$AA` pattern the original ddf tests use. Every plane therefore carries identical bits, the colour index alternates between 0 and 2^N-1 with N planes enabled, and each subsection is a fine vertical comb in its own colour. The eight subsections of a section run through a blue to magenta ramp, in the spirit of the original suite's `$66F`, `$B6F`, `$F6F`, `$F6B`:

```
1 plane  index   1  $66F        5 planes index  31  $E6F
2 planes index   3  $86F        6 planes index  63  $F6F
3 planes index   7  $A6F        7 planes index 127  $F6C
4 planes index  15  $C6F        8 planes index 255  $F69
```

The comb's dark pixels are index 0, which is COLOR00 — the same colour as the zone where no data has arrived. That is exactly how the original suite behaves, and it is what makes the subsection markers work: because index 0 occurs right across the data, a marker written to COLOR00 shows through the comb and spans the full width of the window rather than only the gaps at either end.

The pattern repeats every single word, so BPLxMOD stays zero, pointer drift cannot shear anything, and no fetch-count arithmetic has to be right for the picture to be readable.

KILLEHB is set for the whole frame. Six enabled bitplanes with neither HAM nor DPF set is precisely the condition for Extra Half-Brite, so without it the six plane subsection would draw index 63 as a halved COLOR31 rather than COLOR63 and come out the wrong colour. That is genuine AGA behaviour, but it belongs to Agnus/AGA/killehb, not here.

#### The ten tests

DDFSTRT sweeps in steps of 2, exactly as ddf1 to ddf10 do, with DDFSTOP and FMODE held fixed:

```
agaddf1  DDFSTRT $38     agaddf6   DDFSTRT $42
agaddf2  DDFSTRT $3A     agaddf7   DDFSTRT $44
agaddf3  DDFSTRT $3C     agaddf8   DDFSTRT $46
agaddf4  DDFSTRT $3E     agaddf9   DDFSTRT $48
agaddf5  DDFSTRT $40     agaddf10  DDFSTRT $4A

all ten: DDFSTOP $00C8, FMODE $0000
```

DDFSTOP is $00C8 rather than the $00D0 the old suite resets to, so that the data ends inside the display window in lores as well and the right hand edge stays measurable. FMODE is 0, which makes these ten the direct analogue of the OCS/ECS tests; the other three FMODE values are a matter of copying a wrapper and changing one line.

#### What to expect

**Not every subsection draws, and that is correct.** A fetch unit has eight slots, and how many planes fit depends on how long one word lasts in the current resolution:

```
FMODE 0     lores 8   hires 4   super hires 2
FMODE 1, 2  lores 8   hires 8   super hires 4
FMODE 3     lores 8   hires 8   super hires 8
```

At FMODE 0 the hires section therefore draws subsections 1 to 4 and the super hires section only 1 and 2; the rest stay dark grey across the full width. This is the same limit the Agnus/AGA/shres suite measures, seen from a different angle.

**The left hand gap halves with each resolution step.** The DDF-to-first-pixel latency is a fixed amount of time, so it spans half as many pixels each time the pixel halves. At DDFSTRT $38 it measures 32, 16 and 8 texels in the three sections.

**DDFSTRT is quantised to the fetch unit.** The left edge does not move smoothly through the ten tests; it moves in steps of one fetch unit as DDFSTRT crosses each boundary. That quantisation is a large part of what the suite is for.

**A late DDFSTRT can push the right edge past DIWSTOP.** In agaddf10 the lores band reaches the window edge and the right hand dark grey zone disappears, so the right DDF edge is not measurable in that test. The left edge still is.

#### Notes on the source

The display window is DIWSTRT $2C71 / DIWSTOP $2CC1, wide enough that DIW does not clip the data except in the case noted above.

Each ruler occupies two lines: the bitplanes are switched off on the first so the Copper keeps every slot, and the stripe train runs on the second — a single stripe line, as in the original suite. The stripes alternate white with **blue**, not white with black as the original suite does; black is what BRDRBLNK paints on every neighbouring line, and blue cannot be confused with it. The train's first stripe is red and its last is green, as in the original, which marks where the scale begins and ends.

**BRDRBLNK is cleared for the two ruler lines and set again afterwards.** This is not cosmetic. The ruler lines are the only lines in the frame with BPU = 0, and with no bitplanes enabled the display window never opens, so the entire rasterline is border — there is no window interior for COLOR00 to reach. A blanked border therefore swallows the ruler whole, and on real hardware the earlier revisions of this suite drew no ruler at all while everything else in the picture was correct. Denise/Registers/BPLCON3/brdrblnk2 isolates that behaviour on its own.

The same MOVE re-asserts colour bank 0 with LOCT clear. Nothing else in the Copper list moves BPLCON3, but the ruler is written to COLOR00, and a stray colour bank would send those writes to register 32, 64 or 224 instead of register 0 and the ruler would silently vanish while everything else kept working.

Because the border is unblanked there, a ruler line is also the one place where the full width of the rasterline is visible at once: the stripes run edge to edge rather than stopping at DIWSTRT and DIWSTOP. The window edges are still readable from the neighbouring lines, which are blanked.

That is also why **COLOR00 is set to black by hand around each ruler** rather than left at the dark grey it holds everywhere else. With the border unblanked the grey reaches the full width and would draw a grey band across the ruler's surroundings, butting against the black of the blanked lines above and below. Black is what those lines show anyway, so the seam disappears. The colour is restored on the two lines the ruler occupies and on the lines between the ruler and the next section, which still have no bitplanes enabled and are therefore in the same position; the next subsection's marker puts the dark grey back on its own.

The train ends by leaving COLOR00 at the blue, so each ruler is followed by a wait and a write restoring the dark grey; without it every line below the first ruler would keep the ruler's colour.

The first line of every subsection carries a marker: COLOR00 is switched to dark red at the start of the line, the same device the old DDF tests use to delimit their subsections. It is cleared **past DIWSTOP**, at h=$E1, rather than at h=$D9 as the original tests do. That difference is forced by the eight bitplanes: with all of them enabled, bitplane DMA takes every slot for most of the rasterline and starves the Copper, so a clear placed inside the display window lands at a different position for every plane count and the markers come out visibly ragged. Clearing beyond the window edge makes all twenty-four of them identical.

The frame runs from line $30 to line $128, which fills the display window vertically; DIWSTOP puts its vertical stop at line 300. A Copper WAIT carries only the low eight bits of VPOS, so the list waits out the vertical boundary once with `$FFDF` partway through the super hires section, after which a WAIT on the low byte alone matches lines 256 and up. The original suite uses the same device to wrap into the next frame.

The bitplane pointers are reloaded at the start of every subsection, which bounds pointer drift to ten lines and keeps the buffer small. Eight planes share one buffer, so a single 16 KB block is ample.


Dirk Hoffmann, 2026
