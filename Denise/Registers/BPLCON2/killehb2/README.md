## Objective

Verifies the horizontal timing of BPLCON2::KILLEHB in all three AGA resolutions. It extends `killehb`, which covers LORES and HIRES only, with a SUPER HIRES region, and it makes the three regions directly comparable.

#### Why a second test

`killehb` established that vAmiga switched KILLEHB too early, and that the correction is not the same in both regions: measured against an A1200, hardware puts its HIRES edge 16.6 screenshot columns after its LORES one while vAmiga put it at exactly 16. `Denise::setBPLCON2` therefore carries a resolution-dependent offset that is fitted rather than explained, and super hires was never measured at all.

#### Layout

Three regions of 16 blocks, one block every fourth line, with the `Agnus/DDF/ddf1` copper ruler between them:

```
lines $30-$6F   LORES
line  $70       ruler
lines $75-$B4   HIRES
line  $B5       ruler
lines $BA-$F9   SHRES
```

Six bitplanes throughout with neither HAM nor DPF, the precondition for Extra Half-Brite. Planes 1 and 6 are solid and planes 2 to 5 carry a stripe, so every pixel is color index 33 or 63, and the picture reads as presence versus absence of a pattern:

```
blue/yellow stripes   EHB is killed   (KILLEHB = 1)
flat red              EHB is active   (KILLEHB = 0)
```

Even blocks hold KILLEHB set, drop it, and raise it again, giving a red notch in a striped line. Odd blocks are the inverse. Both end the line with KILLEHB set, so the three lines between blocks are always striped. Switch positions advance four color clocks per block, so the notches form a diagonal, and the same diagonal appears in all three regions.

#### What is different from killehb

`killehb` keeps the stripe 8 pixels wide in the current resolution, so its HIRES stripes are physically half the width of its LORES ones. That is fine for reading one region but useless for comparing them. Here each region gets its own bitplane pattern so that every stripe is 8 lores pixels wide on screen:

```
LORES   $FF00                       8 lores pixels
HIRES   $FFFF,$0000                16 hires pixels  = 8 lores pixels
SHRES   $FFFF,$FFFF,$0000,$0000    32 shres pixels  = 8 lores pixels
```

A switch position can then be compared across regions by eye.

FMODE is $0003 for the whole frame, and it has to be. EHB needs exactly six bitplanes, and six bitplanes in super hires need the 64 bit fetch; at FMODE $0001 a super hires line has slots for at most four. Keeping one FMODE for all three regions also means resolution is the only variable between them. As a side benefit every fetch advances a pointer by eight bytes, which all three stripe periods (2, 4 and 8 bytes) divide, so every line ends in phase and the picture stands still with BPL1MOD and BPL2MOD at zero.

#### The LORES diagonal wobbles

In vAmiga the HIRES and SHRES notches step by exactly 32 columns per pair of blocks and are all 96 wide. The LORES ones step 24, 32, 40, 32 and measure 96, 104, 96, 88, repeating every four blocks.

That is Copper contention, not a broken block. At FMODE $0003 a LORES fetch unit is 32 color clocks against 8 for the other two, so the six bitplane slots bunch at the head of a long unit and a MOVE requested inside the bunch waits for a free cycle.

This is a deterministic prediction about how Agnus hands cycles to the Copper, and the photograph either reproduces it or does not. If it does, the Copper model is sound and any residual disagreement in the switch position belongs to Denise. If it does not, the wobble is the finding.


Dirk Hoffmann, 2026

## Regression testing

Run under `_aga` (A1200_2MB) only. Super hires and the 64 bit fetch are AGA features, and COLOR33 and COLOR63 do not exist below AGA, so no other configuration can carry the test.
