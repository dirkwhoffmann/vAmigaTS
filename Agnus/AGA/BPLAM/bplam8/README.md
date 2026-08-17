## Objective

bplam7 with **every second Pacman left out of both columns**, so that the
picture alternates between bands where a sprite crosses the window edge and
bands where no sprite is involved at all.

bplam7 can say how much of a sprite survives the window sweep. It cannot say
what the same columns look like with no sprite on the line, because in
bplam7 there is a sprite on very nearly every line — sixteen lines of
Pacman, a two line gap, sixteen more. Two lines of gap are not enough to
read anything off, and they fall in the same place in every repeat, so
anything the sprite machinery leaves behind is present almost everywhere and
there is nothing clean to compare it against.

The whole change is two equates:

```
SPR_PERIOD   36 instead of 18
SPR_REPS      8 instead of 15
```

which gives, in each column and repeating down the whole picture:

```
16 lines    a Pacman crosses the window edge
20 lines    no sprite anywhere on the line
```

`SPR_TOP` is unchanged and 36 is a multiple of 18, so the eight Pacmen that
remain are on exactly the lines bplam7's even numbered ones are on. bplam7
and bplam8 can be laid on top of each other row for row.

## Why the bands land where they do

The sprite bands and the window sweep have different periods, and that is
what makes the picture useful. A section is two ruler lines and then six
subsections of fourteen lines; DIWSTRT is constant inside a subsection and
steps between them. The sprite period is 36. The phase of the sprite band at
the top of subsection *k* is therefore `(2 + 14k) mod 36`:

```
subsection   0    1    2    3    4    5
phase        2   16   30    8   22    0
```

Six different phases, all distinct, so no two subsections of a section are
cut the same way. Ten of the eighteen subsections in the picture contain
**both** sprite lines and sprite-free lines, which means ten different
DIWSTRT positions can be read with the sprite present and absent *at the
same DIWSTRT*. That is the comparison the test exists for: same bitplanes,
same palette, same window position, same everything, sprite or no sprite.

```
             $2A+2+14k        sprite lines   sprite-free lines
lores  sub0    $2C-$39             14                0
       sub1    $3A-$47              0               14
       sub2    $48-$55              8                6      <- pair
       sub3    $56-$63              8                6      <- pair
       sub4    $64-$71              0               14
       sub5    $72-$7F             14                0
hires  sub1    $90-$9D              8                6      <- pair
       sub2    $9E-$AB              8                6      <- pair
       sub5    $C8-$D5              2               12      <- pair
shres  sub0    $D8-$E5              8                6      <- pair
       sub1    $E6-$F3              8                6      <- pair
       sub4   $110-$11D             2               12      <- pair
       sub5   $11E-$12B             6                8      <- pair
```

The subsections with 14 and 0 are useful too, just differently: a whole
subsection of sprite lines sits immediately above or below a whole
subsection of sprite-free ones, which is the same comparison one DIWSTRT
step apart.

## What it measures

This is the test for the border artifact. The sprite gate opens one lores
pixel before the bitplane gate —

```cpp
static constexpr Pixel SPRITE_LATENCY = BPLDAT_LATENCY - 4;
```

— and in that gap `PixelEngine::removeBorderOverSprites` clears the border
wherever a sprite pixel sits, so a transparent sprite pixel there ends up
showing the background colour instead of the border colour. bplam7 painted
the Pacman body out precisely so that this could be read without colour
bleeding; bplam8 supplies the missing half of the reading, a line with no
sprite on it.

Measured on the recorded reference, taking one sprite-free line and one
sprite line from the middle of the same subsection, and listing the screen
columns that are **border on the sprite-free line and picture blue on the
sprite line**:

```
             sprite-free   sprite   border -> picture
lores  sub3      $062       $058    column 58
hires  sub1      $092       $09B    column 58
shres  sub0      $0DA       $0E3    columns 41, 42
shres  sub1      $0F2       $0E8    columns 41, 42
lores  sub2, hires sub2, shres sub5   none
```

Two columns in super hires is the whole of `SPRITE_LATENCY` — four buffer
entries, one lores pixel, two screenshot columns. Lores and hires show one
column of it. The subsections that show nothing are the ones where the
sprite does not reach into the gap at that DIWSTRT at all, either because it
is entirely clipped away or entirely inside the window; that they show
nothing is a check on the others, not a gap in the test.

## Reading the picture

The Pacman body is `colour[BPLAM]`, the same blue the playfield draws its
index 0 pixels in, so it has no edge against the picture. The eyes keep
COLOR18 and COLOR19 and are the only visible mark of a sprite — eight rows
of them down the right hand column, one per band, instead of bplam7's
fifteen.

bplam7's caveat carries over unchanged: the eyes sit at sprite pixels 6 to 8,
near the left of the figure, which is the part the window clips first, so in
the lores and hires sections the **left** column has no visible landmark at
all. In this test that costs nothing. A sprite band is identified by the
bands above and below it, not by anything inside it, and the measurement is
a colour comparison between two rows rather than the location of a feature.

Dirk Hoffmann, 2026
