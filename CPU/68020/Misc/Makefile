# Top-level Makefile for the vAmiga regression test suite
# (C)opyright Dirk W. Hoffmann, 2022
#
# To run all regression tests:
#
# 1. Install Image Magick
#    
#    `brew install imagemagick`
#
# 2. Copy Kickstart 1.3 to /tmp
# 
#    `cp /path/to/Kickstart/kick13.rom /tmp`
#
# 3. Specifiy the vAmiga executable
#       
#    `export VAMIGA=/path/to/the/vAmiga/executable/under/test`
#
# 4. Run tests
#
#    `make [-j<number of parallel threads>] 2>&1 | tee results.log`
#
# Note: 
#   
#    The old Makefile used raw2tiff to generate preview images (`brew install libtiff`)
#    raw2tiff -p rgb -b 3 -w 716 -l 285 /tmp/$(TMPID).raw $(basename $@)_fail.tiff; \
#    raw2tiff has vanished in macOS. Therefore, the new Makefile uilizes imagemagick

# Check if we're ready to go
KICK13 = /tmp/kick13.rom
ifndef VAMIGA
VAMIGA = /tmp/vAmiga/vAmiga.app/Contents/MacOS/vAmiga
export VAMIGA
endif

ifeq (,$(wildcard $(VAMIGA)))
    $(error vAmiga executable not found)
endif
ifeq (,$(wildcard $(KICK13)))
    $(error $(KICK13) not found)
endif

# A test's temporary files are named after its position in the tree, not just
# after the script. 244 script basenames occur in more than one family, and two
# runs that touch the same name at the same time -- two make invocations, or a
# parallel recursion -- would otherwise share /tmp/<name>.adf and read each
# other's disk image. The same string is baked into the RetroShell scripts.
GROUP  := $(notdir $(patsubst %/,%,$(dir $(CURDIR))))
FAMILY := $(notdir $(CURDIR))
TMPID   = $(GROUP)_$(FAMILY)_$(basename $(@F))

# Collect all RetroShell scripts
RETROSH=$(wildcard */*.retrosh)
LOG=$(RETROSH:.retrosh=.log)
RAW=$(RETROSH:.retrosh=.raw)
TIFF=$(RETROSH:.retrosh=.tiff)

.PHONY: all prepare clean

all: $(LOG) $(RAW) $(TIFF)
	@echo > /dev/null
		
tiff: $(TIFF)
	@echo > /dev/null

raw: $(RAW)
	@echo > /dev/null

clean:
	@rm -f */*.log
	@rm -f */*_fail.*

%.log: %.tiff %.raw
	@cp $(wildcard $(dir $@)*.adf) /tmp/$(TMPID).adf
	@$(VAMIGA) $(basename $@).retrosh &> /dev/null
	@diff /tmp/$(TMPID).raw $(basename $@).raw; \
	RETVAL=$$?; \
	if [ $$RETVAL -eq 0 ]; then \
		echo "$(basename $@): PASS"; \
		echo "$(basename $@): PASS" > $@; \
    else \
		echo "$(basename $@): **** FAIL ****"; \
		magick -depth 8 -size 716x285 rgb:/tmp/$(TMPID).raw $(basename $@)_fail.tiff; \
		cp /tmp/$(TMPID).raw $(basename $@)_fail.raw; \
	fi
	@rm /tmp/$(TMPID).adf
	@rm /tmp/$(TMPID).raw

%.raw:
	@echo "Creating missing raw image $@"
	@cp $(wildcard $(dir $@)*.adf) /tmp/$(TMPID).adf
	@$(VAMIGA) $(basename $@).retrosh &> /dev/null
	@mv /tmp/$(TMPID).raw $(basename $@).raw
	@rm /tmp/$(TMPID).adf

%.tiff: %.raw
	@echo "Creating missing TIFF image $@"
	# @raw2tiff -p rgb -b 3 -w 716 -l 285 $(basename $@).raw $(basename $@).tiff
	@magick -depth 8 -size 716x285 rgb:$(basename $@).raw $(basename $@).tiff
