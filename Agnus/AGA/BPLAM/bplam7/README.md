## Objective

bplam5 with the Pacman body painted out, so that colour bleeding on a real monitor has nothing to smear across the measurement.

Everything else is bplam5 exactly: the same bitplanes, the same palette, the same window sweep, the same two sprite columns at lores `$73` and `$1B9`. One colour differs.

## What changed and why

In bplam5 the body is yellow against a blue picture. That is easy to see, which is the point, but it is the worst case for reading where the window clips the column: a hard yellow-to-blue edge is exactly what a monitor smears, and the smear is wider than the effect being measured.

Here COLOR17 takes the colour the playfield draws its index-0 pixels in — colour[BPLAM] — so the body has no edge against the picture at all. It is computed with the same `.makeColor` the palette loop uses rather than written as a literal, so it matches to the low nibble. The emulator confirms it: the 2736 pixels that were `ffff00` in bplam5 are `000072` here, and the count of `000072` rises by exactly that.

The eyes are untouched, in COLOR18 and COLOR19. They are the only thing that still marks the sprite.

## Read this together with bplam5

bplam5 says how much of the sprite survives the clip; bplam7 says the same thing without the bleeding. The two should agree.

## What the eyes can and cannot show

The eyes sit at sprite pixels 6 to 8, near the left of the figure — which is the part the window clips first. So they do not survive everywhere:

```
             left column     right column
lores             0 px            30 px
hires             0 px            30 px
super hires      33 px            45 px
```

In lores and hires the left column shows **nothing at all**: its body is invisible by design and its eyes are clipped away. That is a real limitation of painting the body out, not a fault in the picture — the left column is still there, and bplam5 photographed at the same window positions shows where. The right column keeps its eyes everywhere, and super hires keeps them on both sides, so a photograph still proves the sprites are being drawn.

If the left column needs a landmark in lores and hires as well, the eyes would have to move to the right of the figure, which is a different test rather than a variant of this one.

Dirk Hoffmann, 2026
