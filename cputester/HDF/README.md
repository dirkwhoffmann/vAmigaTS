# Overview

The HDF files in this directory contain CPU test programs generated with cputester. To perform a test run in vAmiga, perform the followings steps:

- Enable 8MB Fast Ram
- Select the CPU model under test (68000, 68010, 68020, 68030, or 68040)
- Drag the HDF file into the emulator and reboot
- When the CLI prompt appears, type `cputest all`

Note:

 - The test data is located in directory `data/x_default` where x indicates the CPU type (M68x00).


## Troubleshooting:

- "Couldn't allocate tmem area ..."

This error message indicates that no FastRam is enabled. Enable 8MB FastRam and reboot. 

-  "Couldn't list directy 'data/x_default'"

This error message indicates that the HDF does not contain test data for the emulated CPU type. Select the proper CPU and reboot. 

The HDFs have been generated with the following settings:

### simple_0x0.hdf

Supported CPUs: 68000, 68010, 68020, 68030, 68040

```
test_rounds=2
feature_flags_mode=0
feature_sr_mask=0x0000
feature_undefined_ccr=1
feature_full_extension_format=1
mode=all
```

### simple.hdf (DEPRECATED)

Covered CPUs: 68000, 68010, 68020, 68030, 68040

```
test_rounds=2
feature_sr_mask=0x0000
feature_undefined_ccr=1
mode=all
```

### extmodes.hdf (DEPRECATED)

Covered CPUs: 68020, 68030, 68040

```
test_rounds=2
feature_sr_mask=0x0000
feature_undefined_ccr=1
mode=all
feature_full_extension_format=2
```