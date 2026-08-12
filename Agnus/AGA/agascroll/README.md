## Objective

Verifies the AGA scroll fields of BPLCON1. On OCS and ECS the register holds a 4 bit delay per playfield, 0 to 15 lores pixels. AGA widens it to 8 bits, giving 256 values that cover 64 lores pixels in quarter pixel steps, and only a 64 bit fetch (FMODE = $3) buffers enough data for the whole range to be usable. All tests here therefore set FMODE to $3.

This suite is the AGA counterpart of Denise/Registers/BPLCON1/simple\<n\>, which sets DDFSTRT to $38 + n and runs BPLCON1 through $00, $11, $22 ... $FF. The colour scheme, the block structure and the single bitplane are carried over unchanged; what differs is the value being swept and the encoding it needs.

#### The register layout

The 8 bit value PF1H7-0 is not contiguous in BPLCON1. The ECS field keeps bits 3-0 so that ECS code keeps working, and the four added bits go into the gaps:

```
bit 15-14   PF2H7-6      bit 13-12   PF1H7-6
bit 11-10   PF2H5-4      bit  9-8    PF1H5-4
bit  7-4    PF2H3-0      bit  3-0    PF1H3-0
```

The value is a delay in SHRES pixels, i.e. quarter lores pixels, so 0 to 255 spans 64 lores pixels and any value below 16 still means exactly what it means on ECS. agascroll.i's `SCROLL` macro is the only place this scattering is encoded.

Worth knowing before reading a result: vAmiga models a different layout. It takes the coarse bits from bits 11-10 and 15-14, ignores bits 13-12 and 9-8 entirely, and ends up with a 64 lores pixel range in 16 steps rather than 256. The four blocks below do not land in the same places under the two models, which is a large part of the point of the test.

#### agascroll0 to agascroll14

Each test is a thin wrapper that defines DDF_START and includes agascroll.i. DDFSTRT runs $38 + n for n = 0, 2, 4 ... 14, mirroring simple\<n\>. At FMODE = $3 a fetch spans eight color clocks, so the series walks DDFSTRT across a whole 64 bit fetch unit and a little beyond it.

DDFSTOP, DIWSTRT and DIWSTOP are the same in all eight tests. In particular the display window is not derived from DDFSTRT: the window stays put so that moving DDFSTRT moves the data inside it.

#### Layout of a frame

Four colour blocks of 24 lines in a LORES region, the copper timing ruler from the Agnus/DDF/ddf1 test, then the same four blocks again in HIRES. There are nowhere near 256 display lines to spare, so rather than one value per block each block sweeps a 24 value window, one value per line:

```
block 1 (blue)      0 - 23        0    - 5.75  lores pixels
block 2 (violet)   64 - 87       16    - 21.75
block 3 (magenta) 128 - 151      32    - 37.75
block 4 (pink)    232 - 255      58    - 63.75
```

The windows sit 64 apart, i.e. 16 lores pixels apart, so the four blocks sample the four quarters of the AGA range while each block resolves the fine end of the field. Block 4 is offset by 40 rather than 64 because it runs up against 255; it is the one that shows what happens at the top of the range.

Every fourth line of a block has its background switched to red for the length of the line. That splits each block into six groups of four and makes it possible to say which of the 24 values a given line is showing.

Both playfields are written with the same value. Only one bitplane is enabled, so only PF1H should matter, but a machine that routes odd planes through the PF2 field instead still produces a coherent picture rather than a torn one.

#### The picture

The bitplane buffer is one long repetition of an 8 byte period holding a single 8 pixel bar, so the display is a train of thin bars 64 lores pixels apart. 64 lores pixels is exactly the AGA scroll range, so sweeping the value from 0 to 255 slides the train by exactly one period and the picture at 256 would be the picture at 0 again. Reading the test means watching a bar's left edge walk right as the value climbs, and checking that block 4 has walked almost all the way to the next bar's starting position.

BPL1MOD is zero and the bitplane pointer is reloaded on every display line, which is what makes the picture independent of how many words a line actually fetches. Letting the pointer run and relying on the data being periodic would need a line to consume a whole number of 8 byte periods, and it does not: at FMODE = $3 the per-plane count is `(DDFSTOP - DDFSTRT) / 8 + 4` words, so a $38 to $B0 window fetches 19 words = 38 bytes, and 38 mod 8 = 6 would shear the picture by 48 lores pixels per line. No single DDFSTOP fixes that for all eight variants, because DDFSTRT is the thing being swept. Reloading per line sidesteps the arithmetic instead of trying to satisfy it, and is affordable only because there is a single bitplane: two copper MOVEs per line, patched into the list at startup.


Dirk Hoffmann, 2026
