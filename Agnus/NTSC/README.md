## Objective

Run the Amiga in NTSC mode and modify related bits in VPOSW and BEAMCON0.

#### ntsc0

Draws some Copper bars. Every frame is made a short frame. 

#### ntsc1, ntsc2

Same setup as ntsc0. In addition, the LOL bit in VPOSW is modified in various ways.

#### ntsc3, ntsc4

Same setup as ntsc0. In addition, Agnus is forced to run in PAL (NTSC) mode by setting (clearing) bit 5 in BEAMCON0.

#### ntsc5

Same as ntsc0 with BEAMCON0::LOLDIS = 1 and BEAMCON0::PAL = 0.


Dirk Hoffmann, 2022