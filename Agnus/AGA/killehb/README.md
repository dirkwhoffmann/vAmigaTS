## Objective

Verifies the KILLEHB bit (bit 9 of BPLCON2), which suppresses Extra Half-Brite mode on ECS and AGA machines.

#### killehb

The whole frame is drawn with 6 bitplanes and neither HAM nor DPF set, the standard precondition for Extra Half-Brite. The bitplane data is deliberately trivial and consists of only two buffers, shared by all six planes: planes 1 and 6 point at a solid $FFFF buffer, contributing a fixed 1 + 32 = 33 to the color index, and planes 2 to 5 all point at a single $FF00 buffer, contributing either 0 or 2 + 4 + 8 + 16 = 30. Every pixel is therefore either color index 33 or color index 63, and the picture is an 8 pixel wide stripe pattern.

What those two indices display depends entirely on KILLEHB:

- With EHB killed, the indices address COLOR33 and COLOR63 directly. Those are set to blue and yellow, so the stripe pattern is visible.
- With EHB active, Denise substitutes COLOR(n-32) at half brightness. Index 33 takes COLOR01 and index 63 takes COLOR31 (not COLOR63; 63-32 = 31). Both of those registers are set to red, so the two indices collapse onto one color and the stripes vanish into a flat red field.

The test therefore reads as presence versus absence of a pattern rather than as a difference in shade:

```
blue/yellow stripes   EHB is killed   (KILLEHB = 1)
flat red              EHB is active   (KILLEHB = 0)
```

KILLEHB is the resting state here, so the screen is striped throughout with red punched into it a few lines at a time. The stripes are full brightness, straight out of COLOR33 and COLOR63 with no halving. It is the red that is halved: COLOR01 and COLOR31 hold full red, and EHB displays them with every channel divided by two. A dark red rather than a bright one is the mode working, not a palette error.

The screen consists of a LORES stripe field, the Copper timing ruler from the Agnus/DDF/ddf1 test with all bitplanes disabled, and a HIRES stripe field. The stripe is 8 pixels wide in whatever the current resolution is, so the HIRES stripes come out half the physical width of the LORES ones.

The Copper drives KILLEHB from a block placed on every fourth line of both regions, alternating two patterns:

- Even blocks start the line with KILLEHB already set, drop it at a horizontal position, and raise it again before the line ends. This gives a flat red notch in an otherwise striped line.
- Odd blocks are the inverse. The line starts with KILLEHB clear, it is raised for a stretch, dropped again, and finally raised at the end of the line. This gives a striped notch in an otherwise flat red line.

The switch positions advance steadily down the screen, so the notches form a diagonal. Both patterns leave KILLEHB set at the end of the line, so the three lines between blocks are always striped and every block is read against the same background.

Two properties of the test are worth knowing about when reading the source:

FMODE is set to $0001 (32 bit fetch). At FMODE = 0, a HIRES line fetches only bitplanes 1 to 4 because the fetch unit has no slots for planes 5 and 6, so plane 6 would never arrive and the HIRES region could not reach index 33 or 63 at all.

Both bitplane buffers repeat every single word, so drift of the bitplane pointers cannot be seen. BPL1MOD and BPL2MOD are therefore left at zero and the pointers simply run from one line into the next, which removes any dependency on getting a fetch word count right.


Dirk Hoffmann, 2026
