## Objective

A companion to brdrblnk1, in this same directory. That test always has at least one bitplane enabled, so the display window is a real window and BRDRBLNK only ever touches the area outside it. This test removes the bitplanes entirely and asks a different question:

> With BPU = 0, is the whole rasterline border?

The suspicion is that it is. Nothing is fetched and nothing is displayed, the display window never opens, and the area DIWSTRT and DIWSTOP delimit is border like everything else — in which case BRDRBLNK blanks that too, and a plane-less line comes out uniformly black no matter what COLOR00 holds.

That is not an academic point. A Copper colour ruler is conventionally drawn on a plane-less line, precisely so the Copper keeps every DMA slot and the stripe train runs undisturbed. If BPU = 0 means "all border", a ruler drawn with BRDRBLNK set is invisible — which is exactly what the Agnus/AGA/AGADDF suite ran into on real hardware, with every other part of its picture correct.

## How the screen is built

No bitplanes are ever enabled and bitplane DMA is never switched on, so COLOR00 is the only colour register the machine can reach and every pixel on screen is whatever COLOR00 held at that moment — unless BRDRBLNK blanks it to black. ECSENA (BPLCON0 bit 0) is set throughout, because BRDRBLNK does nothing without it.

DIWSTRT and DIWSTOP are nevertheless set to ordinary values ($2C71 / $2CC1). They are the control:

```
whole line goes black           a plane-less line is entirely border
coloured band, black at both    the window still counts as window
  edges
```

The two outcomes cannot be mistaken for one another.

## The sixteen blocks

The frame runs from line $30 to line $EF, divided into sixteen blocks of twelve lines. Every block has the same shape:

```
line +0     BRDRBLNK clear, COLOR00 = dark blue    plain background
line +1     the Copper ruler, with a BRDRBLNK toggle inside it
line +2,3   BRDRBLNK set for the whole line        expect solid black
line +4..   BRDRBLNK clear again                   background returns
```

**Lines +2 and +3 are the whole-line control.** They answer the question on their own, with no timing subtlety involved: two solid black bars if a plane-less line is all border, a dark blue band between two black strips if it is not.

**Line +1 is the measurement.** It carries the forty back-to-back COLOR00 moves of the Agnus/DDF/ddf1 ruler, one move per four colour clocks, with the stripes alternating **yellow** and **red** rather than white and black — black is what BRDRBLNK paints, and a ruler that already contained black could not be told apart from a blanked one. The first stripe is white and the last is green, marking where the scale begins and ends.

One move of that train is replaced by a write of BRDRBLNK to BPLCON3, and it sits two stripes further right in each successive block:

```
block 0   stripe 2        block 8    stripe 18
block 1   stripe 4        ...
...                       block 15   stripe 32
```

Replacing a move rather than inserting one is deliberate: the train stays exactly forty moves long and every stripe keeps its position, so all sixteen rulers share one scale. The replaced stripe simply keeps the previous colour for twice as long, and that double-width stripe is itself the marker for where the toggle happened.

Every ruler then clears BRDRBLNK again at stripe 36, in the same substituting way, so the last few stripes and the green end marker return on every line. That fixed right-hand edge proves the effect is reversible mid-line rather than a one-way latch, and gives each ruler a second landmark to measure the moving edge against.

## What to expect

If the suspicion is right, each ruler reads: coloured stripes from the white marker to the toggle, black from there to stripe 36, then coloured stripes again to the green marker. The black stretch grows by two stripes per block, so the sixteen rulers form a staircase down the screen, and lines +2 and +3 of every block are solid black across the full width.

If instead a plane-less display window is not border, the ruler stripes survive across the window and only the two thin outer strips go black.

## Status

**vAmiga currently draws the second picture.** In the middle of a whole-line block the window area stays dark blue and only the 30 pixels on the left and 14 on the right go black, and the ruler stripes are unaffected by the toggle. On a real A1200 the AGADDF rulers were invisible under the same conditions, which is the first picture. The two do not agree, and this test is the smallest case that shows it.


## Regression testing

Run under two configurations, `_plus` (A500_PLUS_1MB, ECS Denise, BRDRBLNK active) and `_ecs` (A500_ECS_1MB, OCS Denise, BRDRBLNK inert). The collection README explains the pair.

**Both references capture the behaviour described under Status above, which is known to be wrong.** A regression reference records what the emulator does rather than what the hardware does, so it is recorded as it stands; when the border logic is fixed this test will fail by design and both references must be regenerated.


Dirk Hoffmann, 2026
