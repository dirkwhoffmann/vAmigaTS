## Objective

`RDRAM` is **BPLCON2 bit 8** and it exists on AGA only. It does two things at once:

```
the colour registers become READABLE    (they read as bus junk otherwise)
the colour registers become READ-ONLY   (writes to COLORxx are dropped)
```

Both are exercised here, and both are asked in a form that makes a machine
without AGA do the visible opposite. In vAmiga the bit is decoded in
`Denise.h`:

```cpp
static bool rdram(u16 v) { return GET_BIT(v, 8); }
```

the write lock lives at the head of `Denise::recordColorChange`

```cpp
if (isAGA()) {
    // With RDRAM set, the color registers are read-only
    if (rdram()) return;
    ...
```

and the readback in `Denise::peekCOLORxx`, where it is **not implemented**:

```cpp
if (isAGA() && denise.rdram()) {
    result = 0; // TODO
}
```

## The picture

Three things share the frame. `row` below is the row in the 716×285
screenshot; the mapping is `row = line − 26`.

```
rows   0- 17    grey frame, COLOR00 = $555
rows  18-117    the palette ramp        lines $2C-$8F
rows  70- 93      the Copper write probe inside it, lines $60-$77
rows 118-271    the ruler region        lines $90-$129
rows 272-284    grey frame again
```

### Upper half — the readback

Thirty-two vertical bands, one per colour register, eight lores pixels
(one byte of bitplane, sixteen screen columns) each. Five bitplanes in
lores with all modulos at −40, so every line refetches the same forty
bytes and the bands are clean vertical columns. Forty bands over the
window means the indices run 0…31 and then 0…7 again, so every register
is on screen and the low eight are on screen twice.

None of the colours are immediates. `MAIN` seeds the registers, sets
RDRAM, **reads all thirty-two back**, and builds what is displayed out of
what came back:

```
seed[n]      = (n & 15) << 4          plus $00F for n >= 16
displayed[n] = (n & 15) << 8  |  readback[n] & $FF
```

The red nibble is the band index and is always present, so the ramp has a
skeleton no matter what the readback does — the picture can never go
blank, and a band can always be named by its position in the ramp. Green
and blue come from the register file. On a machine that implements RDRAM
they reproduce the seed, and the ramp is yellow, turning white over the
upper sixteen bands where the seed carries blue.

Band 31 is a second, independent probe of the *other* half of RDRAM.
`MAIN` writes `$0FFF` to COLOR31 while RDRAM is still set and then never
touches it again:

```
AGA        the write is dropped, band 31 keeps its seed  $0FF  cyan
otherwise  the write lands,      band 31 is             $FFF  white
```

### The Copper write probe

The same question asked from the Copper rather than the CPU, and with a
vertical extent so it cannot be confused with anything horizontal. At
line $60 RDRAM is set and COLOR01…COLOR08 are written `$0F00`; at line
$78 RDRAM is cleared and the eight are restored to their derived values
(`MAIN` patches those eight Copper words, since it is the only thing that
knows them).

```
AGA        nothing happens, the ramp runs unbroken top to bottom
otherwise  two red rectangles, columns 78-205 and 590-701, rows 70-93
```

Two, because bands 1-8 appear again as bands 33-39 (indices 1-7) on the
right.

### Lower half — the timing

Forty back-to-back moves make a ruler, one stripe per four colour clocks,
starting at HP $31. Slot *i* covers columns `5 + 16i … 20 + 16i`. Within a
line:

```
slot k          magenta marker
slot k+1        BPLCON2 <- RDRAM set
slots k+2..k+9  ordinary ruler moves          <- the eight under test
slot k+10       BPLCON2 <- RDRAM clear
```

The two BPLCON2 moves **replace** ruler moves instead of being inserted
between them. Every line in the region is therefore forty moves long
whatever *k* is, the stripe grid is rigid, and a switched line can be laid
against a control line column by column. Six lines at each end of the
region carry a plain ruler with no BPLCON2 write at all, as the yardstick.

`k` runs 1…29 and advances every two lines, so the frozen run walks across
the picture three times.

```
AGA        magenta from slot k to slot k+10 inclusive
           eleven slots, 176 columns
otherwise  magenta two slots wide (k and k+1), and the stripe at k+9
           doubled as well -- slots k+1 and k+10 write BPLCON2 rather
           than a colour, so the previous colour simply carries over
```

Eleven against two, and it is not subtle. The **edges** are the timing
statement: measured on the recorded AGA reference, the first move dropped
is the one immediately after the BPLCON2 write and the first move to land
again is the one immediately after the write that clears the bit, with no
slot of slack at either end. That is one Copper move — four colour clocks
— of granularity, which is as fine as a Copper-driven test can ask.

In vAmiga this falls out of `pokeBPLCON2` deferring by `DMA_CYCLES(1)`
while `recordColorChange` consults `rdram()` synchronously, so a BPLCON2
write bites one DMA cycle later and the next ruler move, four cycles
away, is already inside the lock. A machine that took one slot longer at
either end would move that edge by sixteen columns, which the ruler
resolves without measurement.

## The two references

```
rdram_aga    A1200_2MB       AGA Agnus, AGA Denise
rdram_plus   A500_PLUS_1MB   ECS Agnus, ECS Denise, bit 8 not decoded
```

**`rdram_aga` records an unimplemented readback.** `peekCOLORxx` returns
0, so `displayed[n]` is `(n & 15) << 8` — a pure red ramp with green and
blue at zero. Bands 1, 2, 17 and 18 come out so dark that the colour
conversion crushes them to `000000`, so each ramp opens with a 48-column
black run covering bands 0-2. That is a convenient wrap landmark, but it
is an artifact: on hardware those bands carry the seed's green. The write
lock, by contrast, **is** implemented, and both probes for it behave
correctly in the reference — band 31 is cyan and the Copper probe leaves
no mark.

`rdram_plus` records the other side of both questions: band 31 white, the
red rectangles present, magenta two slots wide. Its palette is uniform
green-tan because `peekCustomFaulty16` returns the same value for all
thirty-two registers, giving `readback[n] & $FF = $A6` throughout. On a
real A500+ the read returns whatever the bus was holding, which need not
be constant and need not be `$A6`; this half of the reference pins
vAmiga's *model* of a faulty read, not the hardware.

The ruler in `rdram_plus` sits one screen column left of the ruler in
`rdram_aga` throughout — the AGA colour delay, measured independently in
`../colorlag` and `../rulevern`.

## What a photograph decides

```
band 31 cyan on the A1200, white on the A500+
    the write lock is real and MAIN's COLOR31 write was dropped

no red rectangles on the A1200, two on the A500+
    the write lock applies to the Copper too, and holds across 24 lines

a magenta run eleven slots wide on the A1200, two on the A500+
    the lock engages and releases within one Copper move of the BPLCON2
    write; a different edge position measures a different latency

the ramp yellow-to-white on the A1200 instead of red
    RDRAM readback works on hardware, which vAmiga does not yet model
```

The last of those is the one this test exists to force. A photograph of
an A1200 that shows a yellow ramp shading to white over the upper half is
a direct measurement of `peekCOLORxx`, register by register, against a
seed the test wrote itself.

Dirk Hoffmann, 2026
