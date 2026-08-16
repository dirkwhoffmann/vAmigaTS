## Objective

rulevern with the AGA colour delay taken out of the bitplane data, so that the vertical edges come out straight and any **remaining** step is something else.

rulevern shows a step of exactly one screen column at every band boundary on an A1200, because a Copper ruler is made of colour register writes and AGA delays those by one hires pixel while the bitplanes are not delayed. The A1200 photograph of rulevern measures that step at −1.55 photo pixels, or 1.16 screenshot columns, with a spread of 0.06 across four band boundaries. This variant pre-rotates the stripe pattern by that one column.

## Why the lores section is still stepped

The compensation is a rotation of the bitplane pattern, not a scroll register, because only a rotation can move the data by an **odd** number of columns:

```
hires        one bit  = one hires pixel   = one column     ODD
super hires  two bits = two shres pixels  = one column     ODD
lores        one bit  = one lores pixel   = two columns    even
```

Everything else moves in even steps too — BPLCON1 in whole lores pixels (`pixelOffsetOdd` is `(bplcon1 & 1) << 2`, four buffer entries), DDFSTRT in cycles of four columns, the ruler's own HP in units of four or eight columns. An even step can never close an odd gap, so **the lores section cannot be straightened at all.**

It is left uncompensated deliberately. Standing next to two straightened sections, a lores section that still steps by one column is the clearest statement this suite can make that the delay is an odd number of columns — which is to say exactly one hires pixel.

## Reading the picture

```
hires, super hires     upper half straight
lores                  upper half stepped by one column
all three              lower half stepped by four lores pixels, because the
                       ruler starts half a stripe late there (the control)
```

What vAmiga draws:

```
                rulevern    rulevern2
lores              -1          -1
hires              -1           0
super hires        -1           0
```

## Which machine to photograph

This variant is for **AGA**. On ECS there is no delay to cancel, so it comes out wrong there in an informative way: hires and super hires step one column the other way while lores is straight. rulevern is the test to photograph on an ECS machine; the two together bracket the delay from both sides.

Dirk Hoffmann, 2026
