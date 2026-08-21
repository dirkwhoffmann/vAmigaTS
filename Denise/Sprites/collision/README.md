## Objective

Verfify the collision detection bits.

#### sprcoll1 - sprcoll8

These test cases perform multiple sprite/sprite and sprite/playfield collision tests with varying values in CLXCON and visualizes the contents of CLXDAT in form of color bars.

#### sprcoll1d - sprcoll8d

Same as  sprcoll1 - sprcoll6 in dual-playfield mode.

sprcol8 and sprcol8d exhibit a hardware oddity: If playfield 2 doesn't match in single-playfield mode, playfield 1 can't match either. In dual-playfield mode, everything works as expected. 

#### sprcollbrd1 and sprcollbrd2

Whether a sprite that does not reach the display window can still register a sprite/playfield collision. It cannot -- but the reason is worth spelling out, because the CLXCON value used here makes a collision suspiciously easy to trigger.

The pair differs in one number, the sprite's horizontal position, so any difference between the two pictures can only come from where the sprite sits relative to the window edge:

```
sprcollbrd1   sprite at $098, covering $98-$A7 and so straddling DIWSTRT
              $0A0: eight of its pixels fall inside the window

sprcollbrd2   sprite at $080, covering $80-$8F and stopping well short of
              the window: no pixel of it is ever inside
```

DIWSTRT is lores $A0, DIWSTOP is $180, and the single bitplane is filled with `$FF` so every pixel inside the window has colour index 1. CLXCON is `$0FC0` — all six ENBP bits set, all six MVBP bits clear — which makes a match require the relevant bitplanes to read zero. The next section works through what that implies.

#### What the hardware does

Decoding the bit bars out of all six photographs (A500 OCS, A500+, A1200) gives the same answer on every machine:

| test | CLXDAT bits set |
|---|---|
| sprcollbrd1 | bit 15, and **bit 5 (playfield 2 / sprite 0)** |
| sprcollbrd2 | bit 15 only |

Bit 15 is hardwired to 1 and carries no information, so sprcollbrd2 reports no collision at all.

Bit 5 rather than bit 1 is the CLXCON value at work. `$0FC0` sets all six ENBP bits and clears all six MVBP bits, so a match needs the relevant planes to read zero. Playfield 1 is planes 1, 3 and 5, and plane 1 carries the solid `$FF` picture, so inside the window playfield 1 can never match -- bit 1 stays clear. Playfield 2 is planes 2, 4 and 6, none of which is enabled at all, so it reads zero everywhere and matches **unconditionally**. Any sprite pixel Denise examines therefore lights bit 5.

That is what makes the pair a clean test of *where* Denise looks. sprcollbrd1's sprite covers `$98-$A7` and the window opens at `$A0`, so eight of its pixels fall inside and Denise sees them -- the yellow fragment at the left edge of the blue block in the photograph is exactly those pixels. sprcollbrd2's sprite covers `$80-$8F` and never reaches the window, so Denise never examines it and nothing lights up.

Note that this is **not** an OCS/ECS quirk that AGA drops: the A1200 photograph is identical to the A500 ones. It is the ordinary display-window clipping that already governs whether a sprite is drawn at all (border sprites need AGA's BRDSPRT, which is off here).

#### vAmiga

Two bugs, both the same mistake in different places: a collision check that scans pixels outside the display window, where the data buffer reads zero and a CLXCON asking for zero bitplanes therefore matches everything.

**Bit 5, in `checkS2PCollisions`.** sprcollbrd1 was already correct; sprcollbrd2 was wrong, setting bit 5 as well. The routine walked the sprite's pixel span with no window test, so the unconditional playfield 2 match fired on a sprite that is never drawn.

**Bit 0, in `checkP2PCollisions`.** This one is easy to miss, because it is *intermittent*: the routine scans the whole line buffer, and whether a zero pixel survives out there depends on what the previous line left behind. Logging every CLXDAT read across a full run of sprcollbrd1 gave `8021` on 6 reads out of 103 and `8020` on the other 95 — so the bar flickers, and a single screenshot lands on a clear frame most of the time. A reference image can therefore look right while the behaviour is wrong. **When checking a collision bit, sample every frame, not one.**

Both are fixed by skipping pixels whose border buffer entry is not `BORDER_NONE`. After it, sprcollbrd1 reads `8020` on every frame of the run and sprcollbrd2 reads `8000`, matching the photographs exactly. The other thirty-two tests in this directory are byte-for-byte unaffected, and only sprcollbrd2's two references change.

One read still returns `8001`, the very first of the run. That is before the test program writes CLXCON, when the register is still zero — no ENBP bits set means the playfield comparison is vacuous and every displayed pixel is a match, which is what the hardware would do too. It is not part of what these tests measure.

One case remains untested: with AGA's BRDSPRT the sprite really is drawn over the border, and whether collisions are then evaluated there is not something either of these tests can answer. The guard currently skips border pixels regardless.

## Collision detection has to be switched on

`DENISE_CLX_SPR_SPR`, `DENISE_CLX_SPR_PLF` and `DENISE_CLX_PLF_PLF` all default to **false**, and `regression setup` does not turn them on. Every script in this directory therefore begins:

```
denise set CLX_SPR_SPR true
denise set CLX_SPR_PLF true
denise set CLX_PLF_PLF true
```

Without those three lines CLXDAT reads back as zero no matter what the test does, with only bit 15 lit because that bit is hardwired to 1. The references recorded before the lines were added were all in exactly that state: thirty-two pictures that could not fail on anything they were written to measure. Fourteen of the sixteen changed when the options were enabled and the references regenerated. sprcoll1 and sprcoll1d did not, and correctly so — with CLXCON $FFFF nothing matches, and the A500 photograph agrees.

## Two disagreements with the hardware

Now that the readout is live, two of the recorded pictures no longer match the photographs beside them.

**CLXDAT bit 0 is never set.** sprcoll8's A500 photograph lights bit 15, bit 10 and bit 0; the emulator gives bit 15 and bit 10 only. Bit 0 is the playfield 1 / playfield 2 collision, and it stays clear even with `CLX_PLF_PLF` enabled.

**sprcoll8 and sprcoll8d are identical when they should differ.** That pair exists precisely to show the oddity described above, where a playfield 2 mismatch in single-playfield mode suppresses playfield 1 as well while dual-playfield mode behaves normally. The two photographs do differ. The emulator returns bit 15 and bit 10 for both.

Both references record what the emulator does today and will need regenerating when this is addressed.


Dirk Hoffmann, 2020 - 2026
