## Objective

Verfify the collision detection bits.

#### sprcoll1 - sprcoll8

These test cases perform multiple sprite/sprite and sprite/playfield collision tests with varying values in CLXCON and visualizes the contents of CLXDAT in form of color bars.

#### sprcoll1d - sprcoll8d

Same as  sprcoll1 - sprcoll6 in dual-playfield mode.

sprcol8 and sprcol8d exhibit a hardware oddity: If playfield 2 doesn't match in single-playfield mode, playfield 1 can't match either. In dual-playfield mode, everything works as expected. 

#### sprcollbrd1 and sprcollbrd2

On OCS and ECS, Denise registers a sprite/playfield collision against a bitplane value of **zero** at the moment the display window opens, using whatever sprite data is in the shifters at that instant. The sprite need not be visible: it can sit in the border, never be drawn, and still set a collision bit. AGA drops this behaviour.

The pair differs in one number, the sprite's horizontal position, so any difference between the two pictures can only come from where the sprite sits relative to the window edge:

```
sprcollbrd1   sprite at $098, straddling DIWSTRT $0A0, so sprite data is
              present at the exact position where the window opens

sprcollbrd2   sprite at $080, stopping well short of the window, so
              nothing is present at the opening position
```

DIWSTRT is lores $A0, DIWSTOP is $180, and the single bitplane is filled with `$FF` so every pixel inside the window has colour index 1. CLXCON is `$0FC0` — all six ENBP bits set, all six MVBP bits clear — which makes a collision require a bitplane value of zero. Inside the window the value is 1 and nothing can match, and that is the point: the only zero the sprite can meet is the one Denise supplies itself at the window opening, so any bit that lights up came from the border rather than from the picture.

Expected: sprcollbrd1 sets a sprite/playfield bit on OCS and ECS and nothing on AGA; sprcollbrd2 sets nothing anywhere.

**vAmiga fails sprcollbrd2.** It sets the same bit for both, because it collides sprites against colour index 0 right across the border rather than only at the single position where the window opens. The references record that, so the pair will need regenerating when the behaviour is corrected. The hardware photographs are what settle it.

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
