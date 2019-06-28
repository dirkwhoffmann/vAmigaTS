## Objective

This test uses the Copper to modify the BPU bits in BPLCON0 in the middle of a rasterline. Bitplanes are switched on. 

Remember:
- Copper wakes up 2 cycles prior to the horizontal trigger coordinate.
- Copper needs the bus to wake up. If it is blocked, it waits for a free slot.
- It takes 4 cycles until Agnus recognizes the register change. 

## Copper list

    4501 FFFE: WAIT* ($45,$00)
    0100 0200: MOVE $0200, BPLCON0
    4581 FFFE: WAIT* ($45,$80)
    0100 5200: MOVE $5200, BPLCON0
    8801 FFFE: WAIT* ($88,$00)
    0100 0200: MOVE $0200, BPLCON0
    8883 FFFE: WAIT* ($88,$82)
    0100 5200: MOVE $5200, BPLCON0
    D001 FFFE: WAIT* ($D0,$00)
    0100 0200: MOVE $0200, BPLCON0
    D085 FFFE: WAIT* ($D0,$84)
    0100 5200: MOVE $5200, BPLCON0
    FFDF FFFE: WAIT* ($FF,$DE)
    1001 FFFE: WAIT* ($10,$00)
    0100 0200: MOVE $0200, BPLCON0
    1087 FFFE: WAIT* ($10,$86)
    0100 5200: MOVE $5200, BPLCON0
    FFFF FFFE: WAIT* ($FF,$FE)


## Details

    WAIT $80
    55555555555555556666666666666666777777777777777788888888888888889999999999999999
    0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
    ......................................................LL.L.L.LLL.L.L.LLL.L.L.LLL
    ......................................................51.4.2.351.4.2.351.4.2.351
                                                ^ ^ ^   ^   
                                                | | |   |   
                                                | | |   |   
                                                | | |   Change takes effect here
                                                | | Read2, write to BPLCON0
                                                | Read1
                                                Wakeup

    WAIT $82
    55555555555555556666666666666666777777777777777788888888888888889999999999999999
    0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
    .........................................................L.L.LLL.L.L.LLL.L.L.LLL
    .........................................................4.2.351.4.2.351.4.2.351
                                                    ^ ^ ^   ^   
                                                    | | |   |   
                                                    | | |   |   
                                                    | | |   Change takes effect here
                                                    | | Read2, write to BPLCON0
                                                    | Read1
                                                    Wakeup

    WAIT $84
    55555555555555556666666666666666777777777777777788888888888888889999999999999999
    0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
    ...........................................................L.LLL.L.L.LLL.L.L.LLL
    ...........................................................2.351.4.2.351.4.2.351
                                                    ^ ^ ^   ^   
                                                    | | |   |   
                                                    | | |   |   
                                                    | | |   Change takes effect here
                                                    | | Read2, write to BPLCON0
                                                    | Read1
                                                    Wakeup

    WAIT $86
    55555555555555556666666666666666777777777777777788888888888888889999999999999999
    0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
    .............................................................LLL.L.L.LLL.L.L.LLL
    .............................................................351.4.2.351.4.2.351
                                                        ^ ^ ^   ^   
                                                        | | |   |   
                                                        | | |   |   
                                                        | | |   Change takes effect here
                                                        | | Read2, write to BPLCON0
                                                        | Read1
                                                        Wakeup