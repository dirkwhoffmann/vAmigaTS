# Top-level Makefile for the vAmiga regression test suite
# (C)opyright Dirk W. Hoffmann, 2022
#
# To run all regression tests:
#
# 1. Install TIFF tools 
#
#    `brew install libtiff`
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


ifndef VAMIGA
VAMIGA = /tmp/vAmiga/vAmiga.app/Contents/MacOS/vAmiga
export VAMIGA
endif

# Collect all directories containing a Makefile
MKFILES = $(wildcard */Makefile)
SUBDIRS = $(dir $(MKFILES))
MYMAKE = $(MAKE) --no-print-directory

.PHONY: all prebuild subdirs clean

all: prebuild subdirs
	@echo > /dev/null
	
prebuild:
	@echo "vAmiga regression tester" 
	@echo "${VAMIGA}"
		
subdirs:
	@for dir in $(SUBDIRS); do \
		echo "Entering ${CURDIR}/$$dir"; \
		$(MAKE) -C $$dir || exit 1; \
	done

clean:
	@for dir in $(SUBDIRS); do \
		echo "Cleaning up ${CURDIR}/$$dir"; \
		$(MAKE) -C $$dir clean; \
	done
