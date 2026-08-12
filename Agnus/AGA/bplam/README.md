## Objective

Verifies BPLAM, the bitplane color XOR in the high byte of BPLCON4. AGA XORs an eight bit value into every bitplane color index before it reaches the palette:

```
index = bitplane_bits ^ BPLAM
```

It is applied to the finished index, not to the individual planes, so it does two quite different things depending on which bits are set. Within the range the planes can already reach it permutes the palette; above that range it translates the whole picture into a different block of color registers, which is how a four bitplane playfield can be pointed at any of the sixteen 16-register windows of the 256 color palette without touching a byte of bitplane data.

#### bplam

Four bitplanes, and the data is simply the pixel position: plane k holds bit k-1 of x, so the color index counts 0, 1, 2 ... 15 and repeats every 16 lores pixels. Every line is a 16 step color ramp, repeated across the display.

```
plane 1   $5555   period  2 pixels
plane 2   $3333   period  4
plane 3   $0F0F   period  8
plane 4   $00FF   period 16
```

All four patterns repeat every single word, which makes the picture independent of how many words a line fetches: no shear, no drift, BPLxMOD zero and the pointers simply left to run for the whole frame. Nothing here can go wrong for a reason that is not BPLAM.

The palette is the FMODE suite's: hue keyed on the position of the highest set bit of the index, brightness on bit 0. Ten sections of 20 lines sweep BPLAM through $00, then each single bit in turn, then $FF:

```
BPLAM $00              registers   0-15    the reference, a plain ramp
BPLAM $01 $02 $04 $08  registers   0-15    the ramp reordered
BPLAM $10              registers  16-31
BPLAM $20              registers  32-47
BPLAM $40              registers  64-79
BPLAM $80              registers 128-143
BPLAM $FF              registers 240-255
```

The two halves of the sweep read differently, and it is worth knowing which is which before looking at the screen. The low-bit sections keep the same sixteen registers and only change the order in which the ramp visits them, so what you are checking there is that the sequence of hues changes while the set of hues does not. The high-bit sections move the ramp into a block of registers that all share one highest set bit, so the whole band collapses to a single hue family and what you are checking is the jump between families. $80 and $FF land in the same family and are told apart by the ordering and the brightness pattern within the band, not by hue.

$00 is the reference and must look exactly like a plain four bitplane ramp; a final $00 section restores it at the end of the frame.

A copper ruler sits on the first line of every section, with bitplane DMA switched off so the copper keeps every slot. The low byte of BPLCON4 is left at $11 throughout — those are the sprite palette offsets ESPRM and OSPRM, and $11 is the AGA default. Only the high byte moves.


Dirk Hoffmann, 2026
