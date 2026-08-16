## Objective

The tests in this collection are about the colour registers themselves — when a write to one takes effect, rather than what colour comes out.

#### colorlag

Amiberry delays every write to a colour register by **one hires pixel on AGA** and applies it immediately on OCS and ECS. The branch is in `expand_drga_early`, `drawing.cpp`:

```c
if (aga_mode && (... || !denise_vblank_active)) {
    // AGA color changes are 1 hires pixel delayed
    aga_delayed_color_idx = idx;
    ...
} else {
    update_color(idx, rd->v, bplcon2_denise, bplcon3_denise);
}
```

vAmiga had no such delay on any chipset when this test was written — `Denise::recordColorChange` timestamped every write at `agnus.pos.pixel()` with no chipset term, and that is the only place COLORxx is recorded. It does now; see the last section.

This matters more than it looks, because **a Copper ruler is made of nothing but COLOR00 writes**. If the delay is real, every ruler in this suite is drawn one hires pixel further right on an A1200 than on an A500, and any measurement taken against a ruler inherits that offset. The discrepancy first showed up as the blue band in brdrblnk1 appearing to start one pixel further right on an A500+ than on an A1200.

## Why three landmarks

Comparing a ruler against bitplane data across two machines tells you the two moved relative to each other, not which one moved. Every rasterline of every band here therefore carries three independent families of vertical edge:

```
the ruler         40 back-to-back COLOR00 moves, one per 4 CCK.
                  Colour register writes, so this is the family the AGA
                  delay is supposed to move.

the window edges  DIWSTRT and DIWSTOP, black against the ruler because
                  BRDRBLNK forces the border to pure black whatever COLOR00
                  is doing. Positioned by the DIW comparator.

the data bars     one bitplane, buffer filled with three empty words then
                  one solid word repeating, so the window is ruled by
                  narrow bars in COLOR01. Positioned by the bitplane
                  pipeline.
```

Only the first involves a colour write, so a photograph reads unambiguously:

```
ruler moves, edges and bars stay      the colour write is delayed
edges and bars move, ruler stays      the bitplane and DIW paths are
                                      delayed, colour writes are not
everything moves together             a display centring difference, not a
                                      chipset one
```

That third reading is the reason for measuring against two independent landmarks instead of one. A photograph of a different monitor cannot distinguish an absolute shift from a real one, but it cannot fake a change in the *spacing* between two edge families on the same rasterline.

## Reading the picture

Three bands of 24 identical lines — lores, hires and super hires. Every line reloads the bitplane pointer, so each band comes out as clean vertical columns rather than a diagonal drift, and the three edge families can be compared over 24 rows instead of one. Every fifth ruler stripe is yellow so a position can be named when holding two photographs side by side.

In the lores band the landmarks land at these columns: window edges at 80 and 636, ruler boundaries every 16 from 84, data bars 32 wide every 64 from 158. The hires and super hires bands halve and quarter the bar geometry while the ruler keeps its 4 CCK cadence.

DIWSTRT is lores $8A, deliberately **right** of the first bitplane pixel at $7F. The window opens at the first BPL1DAT write rather than at DIWSTRT, so a DIWSTRT to the left of the data would not be a landmark at all — see Denise/Sprites/clip/diwclip.

The ruler runs on lines that have a bitplane enabled, which the rulers elsewhere in this suite avoid. With one bitplane in lores the fetch takes one cycle in eight and the Copper keeps enough slots for a move every four CCK; the recorded references confirm the stripe train stays perfectly regular at 16 columns throughout.

## The two references

`_plus` (A500_PLUS_1MB, ECS Denise) is the reference configuration. `_ecs` (A500_ECS_1MB) pairs an ECS Agnus with an **OCS** Denise, where BRDRBLNK does nothing, so the border takes COLOR00 and the window-edge landmark is lost; the ruler and the bars survive, which is enough for the colour-timing question on a third chipset. Super hires is likewise inert there.

**vAmiga now implements the delay.** `Denise::recordColorChange` adds `COLOR_LATENCY`, two buffer entries at the super hires resolution the buffers run at, when `isAGA()`. Running the same ADF under an AGA configuration moves the ruler and nothing else:

```
             window edges      ruler boundaries        data bars
ECS            0, 636          84, 100, 116, 132     158, 286, 414
AGA            0, 636          85, 101, 117, 133     158, 286, 414
```

One hires pixel, on the colour writes alone. That is the first of the three readings above, and it is what Amiberry predicts.

Neither reference here moved, and neither did any other in the suite: the regression tester has no AGA configuration scheme, so every recorded picture is OCS or ECS and the delay cannot reach them. The change is therefore invisible to the whole regression suite, which is exactly why it needs a photograph from a real A1200 to confirm rather than refute.

Dirk Hoffmann, 2026
