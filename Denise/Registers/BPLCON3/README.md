## Objective

The tests in this test suite exercise register BPLCON3. At present both of them are about **BRDRBLNK**, bit 5, which forces the border area to pure black instead of letting it take the background colour COLOR00. The bit only does anything when ECSENA (BPLCON0 bit 0) is set, so ECSENA is on throughout both tests.

BRDRBLNK arrived with ECS and is inherited unchanged by AGA. It is not an AGA feature, which is why these tests live here rather than under Agnus/AGA, where they were originally written.

#### brdrblnk1

BRDRBLNK with a bitplane enabled, so the display window is a real window and the bit only ever touches the area outside it. Four regions: whole-line switching against a large border, mid-line switching against a large border, a Copper timing ruler, and switching against a small border read off that ruler.

#### brdrblnk2

BRDRBLNK with **no** bitplanes at all, which asks whether a plane-less rasterline is border across its full width. It is built from sixteen Copper rulers with a BRDRBLNK toggle walking through the stripe train, plus whole-line controls.

## The two configurations

Every test is run twice, and the pair is the measurement:

```
_plus   A500_PLUS_1MB   ECS Agnus, ECS Denise    BRDRBLNK works
_ecs    A500_ECS_1MB    ECS Agnus, OCS Denise    BRDRBLNK does nothing
```

The `_ecs` run is the negative control. BRDRBLNK is a Denise feature, and A500_ECS_1MB pairs an ECS Agnus with an **OCS** Denise, so the bit has no effect there and the border keeps taking COLOR00 throughout. Any difference between the two references is therefore attributable to BRDRBLNK alone, and a `_ecs` reference that ever starts showing black borders means the emulation has begun honouring the bit on a chipset that does not have it.

Both tests write BPLCON4 and FMODE and clear all 256 colour registers through the AGA bank mechanism. On these two ECS configurations those writes are inert — BPLCON4 and FMODE are unimplemented addresses, and the bank bits in BPLCON3 are ignored, so the colour loop simply writes registers 0 to 31 eight times over. Nothing in either picture depends on an AGA-only register, which is what allows the same ADF to serve both the ECS references here and the AGA screenshots taken on a real A1200.

There is no AGA configuration scheme in the emulator's regression tester, so no AGA reference can be recorded at present.

## What the two tests uncovered

Between them these two tests found two independent defects in the border logic, both since fixed. The references here record the corrected pictures and match the A1200 photos.

The first is that a rasterline with **no bitplanes at all** is border across its full width. DIWSTRT does not open the display window on its own; the window opens at the first BPL1DAT write, so with BPU = 0 it never opens and BRDRBLNK blackens the whole line. brdrblnk2's whole-line controls are the smallest case that shows it, and it is why the Copper rulers in Agnus/AGA/AGADDF were invisible on a real A1200 while everything else in that picture was correct.

The second is that BRDRBLNK is a **mid-line** quantity: it takes effect at the pixel the Copper writes it, not from the start of the next rasterline. Both photos say so plainly. brdrblnk1 draws two large staircases across its border areas, and brdrblnk2's rulers go black from the toggle position rightwards, one stripe pair further along in each successive block.

Both `_plus` references changed when these were fixed. Neither `_ecs` reference moved at all, which is precisely what the negative control is supposed to do.


Dirk Hoffmann, 2026
