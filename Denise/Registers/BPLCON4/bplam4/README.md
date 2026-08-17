## Objective

Measure the pixel shift around the border: where the picture actually starts, read against the display window and against a Copper ruler.

bplam1 to bplam3 hold the display window still and sweep BPLAM. bplam4 does the opposite — **BPLAM is a constant and the display window is what moves.** Everything else is bplam3: the same four bitplanes, the same `$5555` / `$3333` / `$0F0F` / `$00FF` pixel-position data, the same 256-entry palette built by `.makeColor`.

The constant BPLAM is what makes the measurement possible. Every index-0 pixel — which is most of the picture, wherever a plane happens to be clear — comes out as colour[BPLAM] instead of COLOR00, so the bitplane data has a hard left edge against a background that is not part of it.

## The six subsections

Three sections, lores, hires and super hires. Each is divided into **six** subsections: three window positions, each run twice, once with the border open and once with it blanked.

```
before    DIWSTRT one step LEFT of the first bitplane pixel
exact     DIWSTRT exactly ON the first bitplane pixel
overlap   DIWSTRT one step RIGHT of it, so the window eats into the data
```

The step is 8 lores pixels. The three positions are placed against the first bitplane pixel of that particular section, which is not the same in all three — at FMODE 1 lores and hires both start at lores `$7F` while super hires starts at `$73`. Those values were measured from a probe build with every window pushed far to the left, not calculated.

Subsections 1-3 run with BRDRBLNK clear, so the border takes COLOR00; subsections 4-6 repeat the same three positions with BRDRBLNK set, so the border is forced to pure black.

## Geometry

The picture runs from line `$2A` to `$12B` — 258 of the 285 rasterlines in the screenshot, and as much of the vertical overscan as a real display can be expected to show. Each section is 86 lines: a two-line Copper ruler and six 14-line subsections.

Two things follow from the height:

The vertical position in a Copper WAIT is only eight bits wide, so the list is re-synchronised once at line 256 with a `WAIT $FFDF` for the end of line 255, followed by a WAIT for line 256 that passes immediately. Everything after it compares against a wrapped counter and behaves normally, which is why the first real wrapped WAIT has to be for line 257 or later.

The four bitplane pointers are rewound at the top of **every subsection**, not once per frame. A super hires line fetches 256 bytes at FMODE 1, so planes left running for the whole picture would read hundreds of lines past the end of their 8 KB buffers and into each other. MAIN patches every one of the eighteen pointer blocks from `ptrBlocks`.

See bplam5 for the same picture with two sprite columns added at the two window edges.

## What to expect

The display window does not open where DIWSTRT says. It opens at the first BPL1DAT write, and DIWSTRT only bites once it has moved past that point — see Denise/Sprites/clip/diwclip, which establishes this separately. So:

```
before and exact    the same left edge, because DIWSTRT is not the
                    constraint in either case
overlap             the edge moves right, because now it is
```

An edge that moves between *before* and *exact* would mean the window is opening at DIWSTRT when it should be opening at the data. An edge that does not move into *overlap* would mean DIWSTRT is not clipping when it should be.

The two border settings are the second axis. The stretch between DIWSTRT and the first bitplane word is border, not window, so with the border open it is dark grey like the rest of the border and there is no seam at DIWSTRT at all; with the border blanked it is black. **The edge that can be located is the same one in both, and it must land in the same column.** A left edge that moves when BRDRBLNK is toggled would mean the border is blanked over a different range than it is drawn.

## What the emulator currently draws

Left edge, in screenshot columns, identical in both halves of every section:

```
             before   exact   overlap
lores           62      62       74
hires           62      62       74
super hires     38      38       50
```

*before* and *exact* agree exactly, in all three resolutions and with the border both open and blanked, which is the expected result and confirms the window opening at the data rather than at DIWSTRT.

**The step into *overlap* is 12 columns, not the 16 that 8 lores pixels of DIWSTRT movement would suggest.** That difference of two lores pixels is the pixel shift this test exists to pin down, and it is the number to check against a real A1200. The Copper ruler at the top of each section gives the scale to read it off.

## Notes

FMODE is 1 rather than bplam3's 0: four bitplanes do not fit in a super hires fetch unit at FMODE 0, and the third section would draw nothing at all.

COLOR00 is dark grey rather than bplam3's dark blue, and specifically not black — black is what BRDRBLNK paints, and a background that was already black would make the two halves of every section identical.

Each section opens with a Copper ruler on a plane-less line with BRDRBLNK cleared. A line with no bitplanes is border across its full width, so a blanked border would swallow the stripes; see Denise/Registers/BPLCON3/brdrblnk2.

In the super hires section the bitplane pattern reads as a solid block rather than as stripes. The screenshot is 716 columns of hires pixels, so every second super hires pixel is dropped, and a pattern that alternates on every pixel samples to one constant colour. The left edge — the thing this test measures — is unaffected.

`bplam4.retrosh` runs under `A1200_2MB`, the AGA configuration scheme. It is the first script under Denise/Modes: before that scheme existed the tests here were photo-only, and the numbers above had to be produced by setting the Agnus and Denise revisions by hand. The rest of Denise/Modes could be scripted the same way now.


Dirk Hoffmann, 2026
