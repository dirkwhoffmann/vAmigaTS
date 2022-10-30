## Objective

The purpose of the tests in this suite is to verify several undocumented Blitter features.


#### undocumented1

"There is also undocumented B-shift feature: if BLTBDAT is written when blitter is not running (probably same happens when it is running but thats too undefined currently anyway..), value will be shifted (using current shift value) immediately to B HOLD (which is then used as a static data for following blit(s) if B-channel is disabled). After shift B Old equals B New." (Toni Wilen)


Dirk Hoffmann, 2020
