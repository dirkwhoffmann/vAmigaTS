## Objective

Sprite clipping at the two edges of the display window.

bplam5 is bplam4 with two Pacman sprite columns added and nothing else changed: the same three sections (lores, hires, super hires), the same six subsections each, placing DIWSTRT before, on and after the first bitplane pixel, first with the border open and then with BRDRBLNK set. bplam4 measures that sweep against the bitplane data; bplam5 measures the same sweep against sprites.

```
sprite 0    lores $73, the position where the window opens in the super
            hires section, crossed by the lores and hires sweep at
            $77 / $7F / $87

sprite 1    lores $1B9, straddling DIWSTOP at $1C1 with eight pixels
            inside the window and eight outside it
```

## Why sprites answer a different question

A sprite is gated by the horizontal display window the same way a bitplane is, but the two gates are not identical. Bitplanes also wait for the first BPL1DAT write of the line, which is why bplam4's *before* and *exact* subsections share a left edge — a DIWSTRT to the left of the data does not open the window any earlier. Sprites are armed by that same write, about one lores pixel **earlier**. The left column makes that offset directly visible; the bitplanes cannot show it, because they are the thing it is measured against.

The right column is the control. DIWSTOP never moves, so all eighteen subsections have to clip it in exactly the same column, whatever the resolution and whatever BRDRBLNK is doing.

## What the emulator currently draws

Left column, in screenshot columns, identical with the border open and blanked:

```
              before   exact   overlap      bitplane edge (bplam4)
lores          60-65   60-65    none              62 / 62 / 74
hires          60-65   60-65    none              62 / 62 / 74
super hires    36-50   36-50    50                38 / 38 / 50
```

Three things to read off this:

**The sprite gate opens two columns before the bitplane gate.** 60 against 62 in lores and hires, 36 against 38 in super hires. Two screenshot columns is one lores pixel, which is exactly the offset the sprite logic is supposed to have.

**The sprite gate follows the data, not DIWSTRT.** *before* and *exact* are identical, just as they are for the bitplanes. Moving DIWSTRT left of the first BPL1DAT write buys nothing for sprites either.

**In *overlap* the lores and hires columns vanish completely.** The window opens at column 74 there, and the sprite ends at 69, so nothing of it survives — the sweep has walked the window clean past the column. In super hires the same subsection cuts the Pacman down to its last pixel at column 50.

The right column is clipped identically in all eighteen subsections, as it must be.

## Sprite width in super hires

The left column is drawn at half width in the super hires section: sprite pixels are one screenshot column there against two in the lores and hires sections. That is Denise clocking the sprites at the display resolution, and it is why the super hires Pacmen are legible while the lores ones are reduced to slivers by the same amount of clipping.

## Open question: the last picture line

Line `$12B`, the last line of the picture, draws a flat twelve-column block in COLOR17 in **both** columns instead of the clipped Pacman row that belongs there. It is not a sprite: shifting the whole column vertically so that a different Pacman row lands on that line produces the identical block, so what is drawn does not depend on the sprite data at all.

What it is not:

```
not a timing artifact      identical at 9 and at 14 seconds of run time
not the closing writes     unchanged when the final BPLCON0 write is moved
                           from HP $01 to $31, and when the final BPLCON3
                           write is removed altogether
not the vertical window    unchanged when DIWSTOP is moved from line 300
                           to line 308
```

No other line in the picture is affected, including the last line of the other seventeen subsections. Those cannot show it, though: the anomaly is only visible where a subsection ends on a line that has both sprite data and a window that clips it, and `$12B` is the only line in the picture where both hold. Worth a look at a real A1200 before assuming it is an emulator artifact.

## Notes

BPLAM is `$20` here rather than bplam4's `$10`. Sprites 0 and 1 take their colours from registers 17 to 19, and at `$10` the bitplane data would be painted out of registers 16 to 31 as well — the sprites would come out in playfield colours. `$20` moves the playfield to registers 32 to 47 and leaves the sprite palette alone. It is why the picture is blue here and teal in bplam4.

FMODE is `$0001`: 32-bit bitplane fetches, which four planes in super hires need, with bits 3 and 2 clear so the sprites stay 16 pixels wide.

BPLCON2 is `$0024`, putting both playfields behind all sprites. The columns have to be drawn over the data, not under it.

All eight sprite pointers are patched, not just the two the test uses. DMACON enables sprite DMA for the whole channel set, so sprites 2 to 7 fetch from wherever their pointers were last left and paint whatever they find there — intermittent garbage that depends on what was in chip RAM before the program started. They are aimed at an empty list (`sprNull`, two zero control words) instead. The recorded reference is unaffected by the fix: after a clean `regression setup` the stray pointers happen to land on quiet memory, which is exactly why this kind of bug shows up interactively and not in the regression run.

The sprite lists are built at run time rather than assembled. The picture is 258 lines tall, the vertical position in a sprite control word is nine bits with the ninth in SPRxCTL, and fifteen copies of the same sixteen-line Pacman are needed per column; computing the control words from the line number is less error-prone than writing them out.

Dirk Hoffmann, 2026
