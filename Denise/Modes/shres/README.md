## Objective

Verifies super hires, BPLCON0 bit 6, the AGA display mode that halves the pixel again below hires. The question the suite asks is the one the FMODE suite asked about hires: **how many bitplanes can super hires actually fetch, and does FMODE change the answer?**

That question has a precedent. At FMODE = 0 a hires line fetches only bitplanes 1 to 4, because the fetch unit has no slots for planes 5 to 8, and a non-zero FMODE widens the fetch and lifts the limit to 8. Super hires packs four times as many pixels into a color clock as lores, so whatever its limit is, it should be tighter still.

#### The claim under test

vAmiga's answer is unambiguous, which is what makes it worth checking. `Sequencer::computeBplEventTable` enumerates hires bitplane counts 1 through 8, but for super hires it enumerates only 1 and 2 — and anything above 2 does not degrade gracefully, it falls through to the zero-bitplane fetch unit:

```
case Resolution::SHRES:
    switch (bpu) {
        case 1: computeShresFetchUnit <1> (fm); break;
        case 2: computeShresFetchUnit <2> (fm); break;
        default: computeShresFetchUnit <0> (fm); break;
    }
```

So vAmiga predicts a picture at BPU 1 and 2 and **a black band at BPU 3 through 8** — and it predicts that regardless of FMODE, because the plane count is capped before FMODE is consulted (the function takes `fm`, the switch does not). If an A1200 paints anything at all in the BPU 3 sections, or if a wider FMODE lifts this cap the way it lifts the hires one, that is a real finding.

#### shres00, shres01, shres10, shres11

The four FMODE values ($0-$3), one per test. Each is a thin wrapper that defines FMODE and includes shres.i.

Every frame holds two regions of 8 sections, enabling 1 to 8 bitplanes:

```
lines $30-$8F   HIRES, the reference
line  $90       the copper timing ruler from Agnus/DDF/ddf1
lines $94-$F3   SHRES, under test
```

The hires region is not decoration, it is the control. It says what this FMODE value can fetch when the pixel is merely half a lores pixel rather than a quarter of one, and it is already characterised by the FMODE tests. Reading a super hires section against the hires section directly above it separates "super hires cannot do this" from "this FMODE cannot do this".

Note that BPLCON0 bit 6 alone selects super hires. The HIRES bit is not also set, and is ignored once bit 6 is set.

#### The picture

Deliberately duller than the FMODE tests' staircase. Every bitplane is filled with a pattern that repeats every single word — plane 1 gets `$CCCC` (two pixels on, two off), planes 2 to 8 get solid `$FFFF` — so with N planes enabled the color index alternates between 2^N-1 and 2^N-2 straight across the line. Each section is one flat hue carrying a fine two-pixel comb. The palette is the FMODE suite's: hue keyed on the highest set bit, brightness on bit 0, so the hue counts the bitplanes that arrived and the plane 1 comb never makes that count ambiguous.

The word-periodic pattern is the point. It makes the picture completely independent of how many words a line fetches, so nothing here can shear or drift whatever super hires turns out to do with the DDF window, and a black band means "no data arrived" rather than "the data landed somewhere unexpected". The comb also comes out four times finer in super hires than in hires, which is an independent confirmation that the mode really engaged.

BPLxMOD is zero and the pointers are reloaded once per section, purely to keep the buffers small.

#### shpattern1 to shpattern8

Unlike shres00-11 above, these are **A500+ tests**: super hires is an ECS Denise feature, and nothing AGA is touched. There is no FMODE, no BPLCON3/BPLCON4, no colour banking or LOCT, and no bitplanes 7 and 8. ECS super hires tops out at two bitplanes, so two planes is the ceiling here.

Each plane is fed from its own repeating byte pattern, replicated across every word of its buffer, so the picture is word-periodic and cannot shear or drift whatever super hires does with the DDF window. In HIRES the colour of a pixel is then a direct readout of the two pattern bits at that position -- plane 2 selects the high bit of the index, plane 1 the low one.

Each region sweeps the plane range rather than sitting at the top of it: the upper half runs 1 bitplane, the lower half 2. Plane 2 arrives part way down a region that is otherwise unchanged, so its contribution reads as a horizontal seam rather than having to be inferred by comparing one test against another.

```
lines $31-$5F   HIRES, 1 bitplane    the reference
lines $60-$8F   HIRES, 2 bitplanes
line  $90       the copper timing ruler from Agnus/DDF/ddf1
lines $95-$C3   SHRES, 1 bitplane    under test
lines $C4-$F3   SHRES, 2 bitplanes
```

The plane count is raised by a bare BPLCON0 write, with no blank line and no re-point at the seam. Plane 1 runs on undisturbed across it, and plane 2 starts from the top of its buffer because it never fetched while switched off, so its pointer never moved.

#### Why all 32 colour registers are initialised

Super hires does **not** do a per-pixel palette lookup. ECS Denise cannot look a colour up per pixel at the super hires dot rate, so it takes pixels in **pairs** and concatenates them into one index:

```
index = (pixel1 & 3) * 4 + (pixel0 & 3) + ((pixel0 | pixel1) & 16)
```

Two bitplanes therefore address **COLOR00 to COLOR15**, not COLOR00 to COLOR03, and bitplane 5 would add bit 4 on top for a range of COLOR00 to COLOR31. Denise then splits the register it picked across the pair: the first pixel shows the high bit pair of each RGB nibble (`& $CCC`), the second the low bit pair (`& $333`).

An earlier revision of this test initialised only COLOR00-03. On a real A500+ that painted the whole super hires region as a flat white block of uninitialised registers -- even in the single-bitplane section, where the pairing still reaches COLOR05. Hence the full 32-entry palette. Every nibble in it is drawn from `$0/$5/$A/$F`, values whose high and low bit pairs are equal, so the nibble split hands both pixels of a pair the same colour and a pair reads as one flat patch. (A nibble like `$C` or `$3` would paint the two pixels differently -- worth a test of its own, but not this one.) COLOR00-03 keep their original values, so the HIRES control region still reads black / red / green / blue.

**vAmiga does not implement any of this.** It renders super hires as an ordinary per-pixel lookup, so it never reaches an index above 3 and its reference images are byte-for-byte unaffected by the 32-entry palette. The hardware photographs are the specification here; the emulator output is the thing under test.

The eight tests are the cross product of four rulerBuf bytes and two solidBuf bytes.

The rulerBuf bytes are chosen for what they do at **pair granularity**, because that is the granularity super hires works at. Successive plane 1 bit pairs map to indices `00`->0, `10`->1, `01`->4, `11`->5, so a byte is a four-symbol word over {0,1,4,5}. Bytes that are merely phase shifts of one another collapse to the same super hires picture -- an earlier revision used `00110011` and `11001100`, which are the same word rotated and so were indistinguishable on hardware. The four words below are mutually non-rotational:

| test | rulerBuf (plane 1) | pair word | solidBuf (plane 2) |
|---|---|---|---|
| shpattern1 | `00110011` | 0,5,0,5 -- alternating | `01010101` |
| shpattern2 | `10011001` | 1,4,1,4 -- alternating | `01010101` |
| shpattern3 | `00100111` | 0,1,4,5 -- all four distinct | `01010101` |
| shpattern4 | `00001111` | 0,0,5,5 -- paired blocks | `01010101` |
| shpattern5 | `00110011` | 0,5,0,5 -- alternating | `10101010` |
| shpattern6 | `10011001` | 1,4,1,4 -- alternating | `10101010` |
| shpattern7 | `00100111` | 0,1,4,5 -- all four distinct | `10101010` |
| shpattern8 | `00001111` | 0,0,5,5 -- paired blocks | `10101010` |

**Expected colours on real hardware.** Applying the pairing formula to each test's two patterns gives what an A500+ should paint in its super hires region. All eight now differ. The hires region above is unaffected by pairing and still reads black / red / green / blue.

| test | SHRES 1 bitplane | SHRES 2 bitplanes |
|---|---|---|
| shpattern1 | black / magenta | orange / lt green |
| shpattern2 | red / yellow | violet / pink |
| shpattern3 | black / red / yellow / magenta | orange / violet / pink / lt green |
| shpattern4 | black, black / magenta, magenta | orange, orange / lt green, lt green |
| shpattern5 | black / magenta | green / white |
| shpattern6 | red / yellow | blue / cyan |
| shpattern7 | black / red / yellow / magenta | green / blue / cyan / white |
| shpattern8 | black, black / magenta, magenta | green, green / white, white |

Tests 1 and 4 (and 5 and 8) reach the same two colours but arrange them differently -- alternating every pair versus in blocks of two -- so they remain distinct pictures.

**Reading the super hires region in the vAmiga reference.** The regression screenshot is 716 pixels wide, i.e. hires resolution, so it records only every *other* super hires pixel. A pattern whose even-numbered shres pixels happen to be degenerate will therefore look degenerate in the reference image even when the mode is working: shpattern1, for instance, paints the full black/green/red/blue cycle below the seam in the hires region but only black and red below the seam in the super hires region, because sampling positions 0, 2, 4, ... of the `0,2,1,3` index sequence yields `0,1,0,1`. That is the screenshot subsampling, not a fetch failure. Compare against the hires region above, which is the same planes and the same seam at a pixel twice as wide.

Note that this makes the two halves of a super hires region indistinguishable for some patterns -- shpattern1 shows black and red both above and below its seam -- while others separate cleanly: shpattern5 samples `2,3` below the seam and so goes from black/red to green/blue. That is a property of the reference image, not of the fetch.


#### shblocks1 to shblocks4

Same body as the shpattern family, but built to pin down the **pairing phase** rather than to sweep patterns. One bitplane is held constant and the other carries blocks whose runs grow, so that pair interiors and pair boundaries can be told apart by eye.

Both planes are filled from `$4C3C` = `%0100110000111100`, whose cyclic run lengths are **1, 2, 2, 4, 4, 3**. The fill words are given whole rather than as bytes because a one-word period is the longest that tiles a super hires line without shearing -- the line fetches an odd number of words, so a two-word pattern would walk sideways down the screen.

The run lengths are the point:

- a run of **4** always contains two whole pairs, so its colour is unambiguous whatever the phase;
- a run of **1** always straddles a pair boundary;
- the odd run of **3** must break differently depending on which boundary the pairs sit on, which is what fixes the phase.

| test | bitplane 1 | bitplane 2 |
|---|---|---|
| shblocks1 | `$FFFF` (constant 1) | `$4C3C` blocks |
| shblocks2 | `$4C3C` blocks | `$FFFF` (constant 1) |
| shblocks3 | `$0000` (constant 0) | `$4C3C` blocks |
| shblocks4 | `$4C3C` blocks | `$0000` (constant 0) |

Three of the four carry a built-in control that needs no reference image to check:

- **shblocks1**, 1 bitplane half: plane 1 is solid, so every pair is (1,1) and the band must be a **flat magenta**. Any structure there means something other than plane 1 is reaching Denise.
- **shblocks3**, 1 bitplane half: plane 1 is all zeroes, so the band must be **flat black**.
- **shblocks4**: plane 2 is all zeroes, so enabling it must change nothing -- the 2 bitplane half must be **pixel-for-pixel identical** to the 1 bitplane half above it. If a real machine shows a seam there, plane 2 is contributing something it was never given.

vAmiga satisfies all three controls exactly.


#### shspot1 to shspot16

A direct readout of **which colour register a super hires pixel pair actually reaches**. The other families infer that from blended colours in a photograph; this one lights exactly one register and lets you see where it lands.

The palette is the whole trick: every register is blue, COLOR00 is black, and the single register under test is yellow. A yellow stripe therefore means "the index landed exactly here", and everything else stays blue. The sixteen tests walk the yellow through COLOR01 to COLOR16 and are otherwise identical -- same bitmap, same layout.

All four colours (`$000`, `$00F`, `$FF0`, `$FFF`) use only nibbles `$0` and `$F`, so they survive Denise's nibble split unchanged and a pair reads as one flat patch.

Four super hires sections, separated by white copper bars, each repeating a single 16-pixel pattern (eight pixel pairs). A one-word period is the longest that tiles a super hires line without shearing, which is why the sweep is split across sections rather than laid out in one run:

| section | indices it produces | purpose |
|---|---|---|
| 1 | 0, 1, 2, 3, 4, 5, 6, 7 | first half of the sweep |
| 2 | 8, 9, 10, 11, 12, 13, 14, 15 | second half of the sweep |
| 3 | 0, 0, 5, 5, 10, 10, 15, 15 | runs of four pixels |
| 4 | 4, 1, 14, 11, 4, 1, 14, 11 | pair ordering probe |

Sections 1 and 2 together produce every reachable index exactly once, in order, so the position of the yellow stripe names the index directly.

Section 3 holds each pixel value for four pixels, so its pairs sit well inside a run rather than across a boundary. Indices 0, 5, 10 and 15 appear there whichever way the pairing grid is phased, which makes it the one section that does not depend on that question.

Section 4 pairs values that differ, and pairs them both ways round: (0,1) against (1,0), and (2,3) against (3,2). If the index is built as `pixel1 * 4 + pixel0` those give 4, 1, 14 and 11; if the two pixels were the other way round they would give 1, 4, 11 and 14 instead. Lighting one register tells the two apart.

**shspot16 is the negative control.** Two bitplanes cannot reach COLOR16, because bit 4 of the index only comes from bitplane 5, so it should show no yellow at all.

Where each register is expected to appear:

| test | sections showing yellow | | test | sections showing yellow |
|---|---|---|---|---|
| shspot1 | 1, 4 | | shspot9 | 2 |
| shspot2 | 1 | | shspot10 | 2, 3 |
| shspot3 | 1 | | shspot11 | 2, 4 |
| shspot4 | 1, 4 | | shspot12 | 2 |
| shspot5 | 1, 3 | | shspot13 | 2 |
| shspot6 | 1 | | shspot14 | 2, 4 |
| shspot7 | 1 | | shspot15 | 2, 3 |
| shspot8 | 2 | | shspot16 | none |

vAmiga matches this table for all sixteen.

Note on sizing: the bitmap buffers are emitted into the binary, and eight of them (two planes for each of four sections) add up quickly. Oversizing them pushes the program past the 512K chip RAM boundary, at which point the tail stops being reachable by the bitplane DMA and the display fails outright -- hence the tight `PLANE_SIZE`.


#### shindex1 to shindex5

A complete, bleed-proof readout of **which colour register a super hires pixel reaches**. This family supersedes shspot, which failed for a reason worth recording.

**Why shspot failed.** It packed several different indices into each section and asked which registers lit up. But at super hires a feature two pixels wide does not survive a CRT and a camera: a single black pixel between blue ones bleeds away to a ripple of a few percent. Measured inside an apparently solid blue block of shspot16, the blue channel swings only 34 to 67 with a period of 8 px -- visible as a faint wobble, nowhere near readable as black. The photographs looked like they showed no black at all, which is what sent the analysis down a blind alley. Any test whose answer lives in fine detail is unreadable on real hardware, however clean it looks in an emulator.

**Every section is flat.** Section k repeats just two pixel values, alternating:

```
a b a b a b a b ...      a = k & 3,  b = (k >> 2) & 3
```

The pattern has period two, so any colour function of a window of neighbouring pixels -- whatever its width, whatever its phase -- is also period two, and the section comes out as **one flat colour**. That holds without assuming anything about how Denise builds the index, which is the point: every earlier family in this directory baked in a model that later turned out to be wrong. Sixteen sections cover all sixteen (a, b) combinations, the four constant ones included.

**The index is read off in binary.** Rather than lighting one register at a time and needing 32 tests, the palette encodes the register number: in test j every register whose bit j is set is yellow and the rest are blue. Five tests give five bits, so a section's index is read straight out of which tests show it yellow.

| test | probes |
|---|---|
| shindex1 | bit 0 |
| shindex2 | bit 1 |
| shindex3 | bit 2 |
| shindex4 | bit 3 |
| shindex5 | bit 4 |

A section blue in all five is index 0. Both colours use only nibbles `$0` and `$F`, so they survive Denise's nibble split, and yellow against blue is the most legible pair through a camera.

**Orientation is built in.** The bar above section 0 is four lines thick and the bar below section 15 is two, while every bar between sections is one. Photographs of this machine come out rotated as often as not, and with sixteen identical-looking bands there is otherwise nothing to say which end is which -- an ambiguity that silently inverted the reading of the shspot photographs.

Only four bitplane buffers are needed for all sixteen sections, because each section's planes are one of four repeating words (`$0000`, `$5555`, `$AAAA`, `$FFFF`) and each section re-points to the start of whichever it needs. The binaries are under 10K.

vAmiga renders all sixteen sections flat and decodes to `index = 4a + b`. Whether real hardware agrees is exactly what the photographs are for.


#### The rule, as measured

**Two pixels are combined into one colour index, and the partner is the pixel TWO positions further on:**

```
index = (pixel[p+2] & 3) * 4 + (pixel[p] & 3)
```

so a super hires pixel can reach any of COLOR00 to COLOR15. Bitplane 5 would supply a bit 4, but with two bitplanes it never fires, and shindex5 confirms bit 4 is never set.

The stride is what took longest to find, because most patterns hide it. **Any pattern of period 2, or a constant one, has `pixel[p+2] == pixel[p]`**, so the index collapses to

```
index = 5 * v          reaching only COLOR00, COLOR05, COLOR10, COLOR15
```

That collapsed form is what shindex, sh1bpl, shsplit and shramp all measure -- every pattern they draw is period 2 or constant by construction, so they are structurally blind to the stride and agree with a "no pairing at all" reading. It took shspot, whose patterns have period 16, to separate the two: its sections reach COLOR01, COLOR03, COLOR06, COLOR09, COLOR11 and COLOR12, which `5 * v` cannot produce at all. Fitting the stride against all four shspot sections gives `+2` uniquely and exactly -- every register seen on the A500+ is predicted, with none left over.

The rule is the same for one bitplane as for two (sh1bpl), with `v` simply carrying bitplane 1 alone.

A consequence worth knowing when reading reference images: the regression screenshot records only **even** pixels, so it shows a subset of what a CRT does. For shspot section 1 the emulator's dump reaches COLOR01, COLOR04 and COLOR05 while the full picture also reaches COLOR03, COLOR09 and COLOR14. Both are correct; they are different samples of the same line. A second consequence is a one-column artifact at the trailing edge of the display, where the pairing reaches two pixels past the end of the bitplane data.

vAmiga's `PixelEngine::colorizeShres` implements the rule above.

#### shsplit1

Whether the chosen register is shown whole, or split so one sub-pixel takes the high bit pair of each RGB nibble and the other the low pair. Every shindex palette was built from nibbles `$0/$5/$A/$F`, whose bit pairs are equal, so a split would have been invisible there by construction. shsplit1 uses nibbles where the halves differ -- `COLOR05 = $C00`, `COLOR10 = $300`, `COLOR15 = $F00` -- across four sections of constant pixel value. Read the answer off sections 1 and 2: clearly different brightness means no split, equal mid red means split. vAmiga, implementing no split, renders them 0.70 and 0.11.

#### sh1bpl1 to sh1bpl5

The shindex sweep repeated with a single bitplane. The two-plane rule is settled, but one plane is a separate question: shres00 paints its one-plane super hires band red, i.e. COLOR01, where a replicated single bit would give COLOR05. These five tests probe the index bit by bit exactly as shindex does, with `SHRES_BPU` set to 1. Sections whose bitplane 1 bits agree should be indistinguishable regardless of their bitplane 2 bits.

#### A note on reading these photographs

Two traps cost real time in this directory, both worth avoiding again:

- **Fine detail does not survive the trip through a CRT and a camera.** A single differing pixel at super hires bleeds to a ripple of a few percent. Measured inside an apparently solid blue block of shspot16, the blue channel swung only 34 to 67. Tests whose answer lives in one- or two-pixel features are unreadable on hardware however clean they look in an emulator; every family from shindex onwards makes each section a flat colour instead.
- **Compare the orientation markers as a ratio, not in absolute pixels.** Photographs of this machine come out rotated as often as not. The thick/thin bar scheme works, but a photograph blurs both markers by the same factor, so a two-line marker can measure four pixels and a four-line marker eight. Reading them as absolute line counts inverted the first analysis of the shindex photographs.


#### shramp1 to shramp7

A sweep of the colour register transfer curve: what brightness a given nibble value actually produces in super hires.

shsplit1 ruled out the idea that a register is split across two sub-pixels -- sections carrying `$C00` and `$300` came out clearly unequal, where a split would force them equal. But it turned up something else. `$C00` measured 0.80 of full red, exactly its nominal weight of 12/15. `$300` measured 0.625, where its nominal weight is 3/15 = 0.20. **The high bit pair of a nibble behaves as written; the low pair does not.** That is not gamma -- gamma would bend `$C` too, and `$C` lands on nominal to two decimals.

Four sections, each a constant pixel value so every pixel in it reaches one register:

| section | v | register | contents |
|---|---|---|---|
| 0 | 0 | COLOR00 | `$000`, black anchor |
| 1 | 1 | COLOR05 | `RAMP_A`, under test |
| 2 | 2 | COLOR10 | `RAMP_B`, under test |
| 3 | 3 | COLOR15 | `$F00`, full red anchor |

Both anchors sit in the **same frame** as the two values under test, so each photograph normalises against itself and exposure differences between shots drop out. That matters here in a way it did not for the earlier families: the answer is a brightness rather than a hue, and brightness is exactly what varies between photographs.

Seven tests carry the fourteen nibbles `$1` to `$E`, two per test; `$0` and `$F` are the anchors and are therefore measured in every frame.

| test | nibbles | test | nibbles |
|---|---|---|---|
| shramp1 | `$1`, `$2` | shramp5 | `$9`, `$A` |
| shramp2 | `$3`, `$4` | shramp6 | `$B`, `$C` |
| shramp3 | `$5`, `$6` | shramp7 | `$D`, `$E` |
| shramp4 | `$7`, `$8` | | |

vAmiga, which simply uses the register value, renders a monotonic ramp close to `n/15`. **shramp2 is the decisive one**: if `$3` reads near 0.6 rather than 0.2, the shsplit1 anomaly is confirmed and the rest of the sweep gives its shape.


Dirk Hoffmann, 2026
