## Objective

Verifies the behaviour of Agnus' FMODE register on AGA machines, i.e. how BPL32 and BPAGEM (FMODE bits 0 and 1) affect the size of a bitplane fetch and, in the 64-bit case, how the alignment of the bitplane pointers affects the result.

All tests share the same layout: 8 sections in a LORES region followed by 8 sections in a HIRES region, enabling 1 to 8 bitplanes respectively (the 8-plane case uses BPLCON0::BPU3, an AGA-only bit). A copper timing ruler separates the two regions. All 256 AGA color registers are initialized so the number of enabled bitplanes can be read directly off the hue: red, orange, yellow, green, cyan, blue, magenta, white for 1 through 8 planes.

The shared logic lives in fmode.i. Each test directory is a thin wrapper that defines a handful of equs (FMODE, DDF_START, DDF_STOP_LORES, DDF_STOP_HIRES, and, from fmode11a on, per-plane alignment flags) and includes it.

#### fmode00, fmode01, fmode10, fmode11

Exercise the four FMODE values ($0-$3) in turn, i.e. every combination of BPL32 and BPAGEM. The bitplane data is a repeating 8-byte staircase pattern; plane k switches on at byte k-1 of each period and stays on, so scanning across a line brings in one more plane every 8 pixels and the picture is literally a staircase of hues. BPL1MOD/BPL2MOD are both zero and the bitplane pointers are simply left to run from one line into the next, reloaded only when a new section starts; the DDF window of each test is chosen so a line fetches a whole number of staircase periods, which is what keeps the picture standing still.

Because FMODE changes how many words a fetch delivers without changing the fetch unit itself, the four tests need different DDF windows to paint the same picture (three staircases in the LORES region, six in the HIRES region) -- see the header comment in fmode.i for the fetch-word model this suite settled on.

fmode10 (BPAGEM set, BPL32 clear) is not a documented fetch mode; the 64-bit mode wants both bits set. It exists to pin down what real hardware does with that combination.

#### fmode11a to fmode11j

All ten variants are fmode11 (FMODE=$3, the 64-bit fetch mode) with a subset of the eight bitplane pointers deliberately pushed off their 64-bit boundary. On an A1200, fmode11 was originally found to show only bitplanes 1-4 -- the buffers happened to land 4 bytes short of 64-bit alignment. These tests were built to isolate that finding.

fmode11a-e misalign the pointers by 4 bytes (the maximum offset a still word-aligned pointer can have):

- fmode11a: all eight planes misaligned. Reproduces the original bug.
- fmode11b: planes 1-4 misaligned, 5-8 aligned.
- fmode11c: planes 5-8 misaligned, 1-4 aligned.
- fmode11d: odd planes (1,3,5,7) misaligned, even planes aligned.
- fmode11e: even planes (2,4,6,8) misaligned, odd planes aligned.

fmode11f-j repeat the same five plane subsets with a 2-byte misalignment instead of 4, to test whether only the fact that a pointer sits off its 64-bit boundary matters, or whether the distance from it matters too.

The alignment of each plane is controlled by fmode.i's PLANEk_MISALIGN flags (k = 1-8, default 0 = aligned) and MISALIGN_OFFSET (default 4).


Dirk Hoffmann, 2026
