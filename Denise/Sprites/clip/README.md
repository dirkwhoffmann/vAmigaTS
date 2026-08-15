## Objective

Verify basic properties of the drawable sprite area.

#### clip1 - clip3

These tests verify basic sprite clipping properties in lores mode. They differ in the shift value in BPLCON1.

#### clip1h - clip3h

Same as clip1 and clip2 in hires mode. 

#### newclip \<n>

These tests verify basic sprite clipping properties in both lores and hires mode. Each test keeps DDFSTRT constant and varies the contents of BPLCON1.

#### diwclip \<n>

The companion of newclip. Those tests park a sprite at the left edge of the display window and sweep BPLCON1 down the screen. These hold the sprite still and sweep the **display window** across it instead, and what varies from test to test is DDFSTRT.

The question they answer is which gate clips a sprite. The display window has two: DIWSTRT and DIWSTOP drive a horizontal flipflop, and the first BPL1DAT write of a rasterline arms the output. The two only disagree in the stretch between DIWSTRT and the first bitplane word, so the sweep deliberately begins left of the data and ends right of it:

```
clipped by DIW alone     the bar's left edge follows DIWSTRT for the
                         whole sweep, one step per block

clipped by BPL1DAT too   the bar's left edge sits still at the first data
                         pixel while DIWSTRT is left of it, and only starts
                         moving once DIWSTRT has passed it
```

The second reading puts a **knee** in the staircase, and the knee is where the bitplane data begins. Because DDFSTRT moves the data, the knee moves with it — one block per test, from block 4 in diwclip1 to block 11 in diwclip8. A staircase with no knee cannot do that.

Two probes, and only one of them is the measurement. Sprites 0 to 3 form a solid 64 pixel bar from $06F which DIWSTRT sweeps across; that is the question. Sprites 4 to 7 form a second bar from $181 which DIWSTOP sweeps across; that is the control, because BPL1DAT has long since been written by the time the beam arrives there and both readings predict the same thing. A right probe that misbehaves means the sweep is broken, not that anything has been learnt about the left one.

BRDRBLNK is set, so the border is pure black and COLOR00 inside the window is dark grey, which makes both window edges directly visible. The bitplane buffer is filled with `$FFFF` rather than the `$AA` pattern of the older tests, so the data is a flat hue: every edge in the picture is a window edge or a sprite edge and none of them is a texture. That also gives a second, independent answer to the same question, one that needs no sprite at all — the grey stretch between DIWSTRT and the data either exists or it does not.

Three sections rather than two, lores, hires and super hires, with a Copper ruler between each pair. The rulers are the ddf1 stripe train started at h=$31 and run out to 44 stripes so the scale covers both probes; they are drawn on plane-less lines with BRDRBLNK cleared, because a plane-less line is border across its full width (see Denise/Registers/BPLCON3/brdrblnk2).

**These run under A500_PLUS_1MB, not A500_ECS_1MB like the rest of this directory.** Super hires and BRDRBLNK are both ECS Denise features and A500_ECS_1MB pairs an ECS Agnus with an OCS Denise, where neither works. The same ADF serves for AGA screenshots on a real A1200.

#### diwclip1a

diwclip1 with one extra bit: **BRDRSPRT**, BPLCON3 bit 1, set for the whole frame. That bit is supposed to let sprites be drawn in the border, and both emulators say it cannot do so in diwclip1's configuration, for two independent reasons:

```
it is AGA only          inert on the ECS Denise these references are
                        recorded on

BRDRBLNK overrules it   a blanked border takes no sprites, whatever
                        BRDRSPRT says
```

Neither claim has been checked against hardware, and the second is the interesting one — it is a rule with no test anywhere in this suite. So diwclip1a asks both questions in one frame: BRDRSPRT is on throughout, the border stays blanked for the lores and hires sections, and is **unblanked** for the super hires section.

```
lores, hires   if BRDRBLNK really does overrule BRDRSPRT, pixel for pixel
               identical to diwclip1

super hires    with nothing to overrule it, BRDRSPRT should take effect on
               AGA: the bar stops being clipped and the staircase goes flat
```

One variant is enough. What is being measured is a property of BPLCON3, not of DDFSTRT, so repeating it eight times would only repeat the same answer at eight positions.

The recorded reference confirms both halves on ECS. It differs from diwclip1 in **55912 pixels, every one of them `000000 → 2b2b2b`**, all inside the super hires section: nothing but the border changing from blanked black to COLOR00 grey. The lores and hires sections are untouched, and the super hires staircase is unchanged — the AGA bit is correctly inert. A flat bar there, or any difference in the first two sections, would mean the emulation has begun honouring an AGA bit on a chipset that does not have it.


Dirk Hoffmann, 2020 - 2026
