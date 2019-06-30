## Objective

This test uses the Copper to modify the BPU bits in BPLCON0 in the middle of a rasterline. Bitplanes are switched off. 

Remember:
- Copper wakes up 2 cycles prior to the horizontal trigger coordinate.
- Copper needs the bus to wake up. If it is blocked, it waits for a free slot.
- It takes 4 cycles until Agnus recognizes the register change. 

## Copper list

    4581 FFFE: WAIT* ($45,$80)
    0100 0200: MOVE $0200, BPLCON0
    4601 FFFE: WAIT* ($46,$00)
    0100 5200: MOVE $5200, BPLCON0
    8883 FFFE: WAIT* ($88,$82)
    0100 0200: MOVE $0200, BPLCON0
    8901 FFFE: WAIT* ($89,$00)
    0100 5200: MOVE $5200, BPLCON0
    D085 FFFE: WAIT* ($D0,$84)
    0100 0200: MOVE $0200, BPLCON0
    D101 FFFE: WAIT* ($D1,$00)
    0100 5200: MOVE $5200, BPLCON0
    FFDF FFFE: WAIT* ($FF,$DE)
    1087 FFFE: WAIT* ($10,$86)
    0100 0200: MOVE $0200, BPLCON0
    1101 FFFE: WAIT* ($11,$00)
    0100 5200: MOVE $5200, BPLCON0
    FFFF FFFE: WAIT* ($FF,$FE)
  
## Details

    WAIT ..,$80
    55555555555555556666666666666666777777777777777788888888888888889999999999999999
    0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
    .L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL........................
    .4.2.351.4.2.351.4.2.351.4.2.351.4.2.351.4.2.351.4.2.351........................
                                                ^   ^ ^ ^   ^
                                                |   | | |   |
                                                |   | | |   Change takes effect here
                                                |   | | Read2, write to BPLCON0
                                                |   | Read1
                                                |   Wake up
                                                Wake up not possible, bus blocked

    WAIT ..,$82
    55555555555555556666666666666666777777777777777788888888888888889999999999999999
    0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
    .L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL........................
    .4.2.351.4.2.351.4.2.351.4.2.351.4.2.351.4.2.351.4.2.351........................
                                                    ^ ^ ^   ^   
                                                    | | |   |   
                                                    | | |   |   
                                                    | | |   Change takes effect here
                                                    | | Read2, write to BPLCON0
                                                    | Read1
                                                    Wake up

    WAIT ..,$84
    55555555555555556666666666666666777777777777777788888888888888889999999999999999
    0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
    .L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L....................
    .4.2.351.4.2.351.4.2.351.4.2.351.4.2.351.4.2.351.4.2.351.4.2....................
                                                      ^ ^   ^   ^   
                                                      | |   |   |   
                                                      | |   |   |   
                                                      | |   |   Change takes effect here
                                                      | |   Read 2, write to BPLCON0
                                                      | Read1
                                                      Wake up


    WAIT ..,$86
    55555555555555556666666666666666777777777777777788888888888888889999999999999999
    0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
    .L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.LLL.L.L.L..................
    .4.2.351.4.2.351.4.2.351.4.2.351.4.2.351.4.2.351.4.2.351.4.2.3..................
                                                        ^   ^ ^   ^ 
                                                        |   | |   |
                                                        |   | |   Change takes effect here
                                                        |   | Read2, write to BPLCON0
                                                        |   Read1
                                                        Wake up