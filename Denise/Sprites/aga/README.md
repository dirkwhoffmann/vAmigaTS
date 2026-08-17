## Objective

Verifies the AGA sprite width and scan doubling features. A sprite is 16 pixels wide on OCS and ECS; AGA widens it to 32 or 64 via FMODE bits 3 and 2, and can double it vertically via FMODE bit 15 together with bit 7 of the sprite's own POS word.

```
FMODE bits 3-2    words per DMA read    sprite width
    00                   1                 16 px
    01, 10               2                 32 px
    11                   4                 64 px
```

A sprite performs exactly two DMA reads per rasterline, data A and data B, each of that width, and the pointer advances by the full width on every read. A 64 bit sprite therefore consumes eight words per line rather than two, and the leftmost 16 pixels come from the first word.

The sprite artwork is the Pacman and the ghost from Denise/Sprites/sprdrop, unchanged.

#### simple1

Six sections, one per combination, each with its own sprite channel so that no sprite is reused and there is no pointer chaining between sections:

```
section 1   lines $30-$51   16 px                sprite 0
section 2   lines $52-$73   32 px                sprite 1
section 3   lines $74-$95   64 px                sprite 2
section 4   lines $96-$B7   16 px, scan doubled  sprite 3
section 5   lines $B8-$D9   32 px, scan doubled  sprite 4
section 6   lines $DA-$FB   64 px, scan doubled  sprite 5
```

The copper switches FMODE on the first line of each section, before that section's sprite starts.

The wide sprites are not a scaled up Pacman but a row of figures packed into one sprite, alternating Pacman and ghost:

```
16 px    P
32 px    P G
64 px    P G P G
```

That makes the result readable at a glance and unambiguous about word order. The leftmost figure is always the Pacman from word 0, so if the extension words arrived out of order the P G P G rhythm would break rather than the sprite merely widening. A 32 or 64 bit section that comes out as a lone Pacman means the extension words never reached Denise at all.

The three scan doubled sections use exactly the same sixteen lines of data as the three above them, so they must come out twice as tall and otherwise identical. Scan doubling works by suppressing the data fetch on every second line, the parity anchored at VSTART, so the first line of the sprite is the first line of a doubled pair.

All six sprites are given the same HSTART and should line up in one column. A copper ruler sits on the first line of every section: the stripe train from the Agnus/DDF/ddf1 test, one MOVE per 4 color clocks and therefore one stripe per 8 lores pixels, starting where the playfield starts. Bitplane DMA is switched off on those lines so the copper keeps every slot and the stripes stay evenly spaced. Counting stripes from the red one gives a sprite's absolute position.

Sprites 6 and 7 are unused, but DMACON enables sprite DMA for all eight channels at once and every channel fetches control words on line 25. They are therefore parked on a block whose VSTART and VSTOP are both zero; left unpointed they fetch whatever their pointers happen to contain and display random memory.

The playfield is a single bitplane with every bit set, present only so the display window shows as a rectangle in COLOR01 against a COLOR00 border. Sprites are not drawn over the border unless BPLCON3's BRDSPRT is set, which this test deliberately does not rely on.

#### Two awkward details

**POS bit 7 does double duty, and costs a comparator bit.** Normally it is bit 8 of HSTART, worth 256. With FMODE's SSCAN2 set it instead means "scan double this sprite" — and the horizontal comparator does not merely subtract that bit, it stops evaluating it. That shortens the comparator by one bit, so the sprite is matched **twice per line, 256 lores pixels apart**. Sections 4 to 6 therefore show a second copy of each sprite towards the right of the window. That is correct behaviour, not a fault in the test, and it is arguably the most interesting thing the test shows.

Two consequences follow. The second match is driven by FMODE bit 15 alone rather than by the per-sprite POS bit, so in a scan doubled section every armed sprite doubles horizontally whether or not it is doubled vertically. And because the bit is ignored rather than subtracted, $50 and $D0 in the low byte of POS put the sprite in exactly the same two columns: the doubled sections carry $D0 purely to set the scan doubling flag, not as a position correction. SPR_HSTART is kept below 256 all the same, since bit 8 of it can no longer be used for anything.

**All control words are fetched on the same line.** The vertical trigger of all eight sprites is reset on line 25 (PAL), and every sprite reads its control words there — at whatever FMODE happens to be set at that moment, not at the FMODE of the section the sprite belongs to. The copper therefore sets the 64 bit width at the top of the list, and every control block is laid out with the 4 word stride: POS followed by three pad words, CTL followed by three pad words, regardless of how wide the data that follows it is. The terminating control block at the end of each sprite is different: it is read on that sprite's VSTOP line, inside its own section, so it uses that section's stride.


Dirk Hoffmann, 2026
