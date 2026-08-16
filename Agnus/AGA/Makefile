# Makefile for sub dir level 2
# (C)opyright Dirk W. Hoffmann, 2022
#
# To run all regression tests:
#
#    1. Copy Kickstart 1.3 to /tmp
#       cp /path/to/Kickstart/kick13.rom /tmp
#
#    2. Specifiy where to find the find the vAmiga executable
#       export VAMIGA=/path/to/the/vAmiga/executable/under/test
#
#    3. Run tests
#       make [-j<number of parallel threads>]

ifndef VAMIGA
VAMIGA = /tmp/vAmiga/vAmiga.app/Contents/MacOS/vAmiga
export VAMIGA
endif

# Collect all group directories, i.e. those that hold test folders with a
# RetroShell script. This level cannot use the usual */Makefile wildcard: AGA
# mixes group directories such as BPLAM with plain test folders such as ham8,
# and those carry a build Makefile that only works in the source tree.
SCRIPTS = $(wildcard */*/*.retrosh)
SUBDIRS = $(sort $(dir $(patsubst %/,%,$(dir $(SCRIPTS)))))
MYMAKE = $(MAKE) --no-print-directory

.PHONY: all subdirs tiff clean

all: subdirs
	@echo > /dev/null
			
subdirs:
	@for dir in $(SUBDIRS); do \
		echo "Entering ${CURDIR}/$$dir"; \
		$(MAKE) -C $$dir || exit 1; \
	done

tiff:
	@for dir in $(SUBDIRS); do \
		echo "Entering ${CURDIR}/$$dir"; \
		$(MAKE) tiff -C $$dir || exit 1; \
	done

clean:
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
