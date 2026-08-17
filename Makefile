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


ifndef VAMIGA
VAMIGA = /tmp/vAmiga/vAmiga.app/Contents/MacOS/vAmiga
export VAMIGA
endif

# Collect all directories containing a Makefile. Directories holding a
# build Makefile rather than a test runner are skipped in the loops below.
MKFILES = $(wildcard */Makefile)
SUBDIRS = $(dir $(MKFILES))
MYMAKE = $(MAKE) --no-print-directory

.PHONY: all prebuild subdirs missingini clean

all: prebuild subdirs tiff missingini
	@echo > /dev/null
	
prebuild:
	@echo "vAmiga regression tester" 
	@echo "${VAMIGA}"
		
subdirs:
	@fail=0; for dir in $(SUBDIRS); do \
		if grep -qs '^include .*shared/base.mk' $$dir/Makefile; then continue; fi; \
		echo "Entering ${CURDIR}/$$dir"; \
		$(MAKE) -C $$dir || fail=1; \
	done; exit $$fail

tiff:
	@fail=0; for dir in $(SUBDIRS); do \
		if grep -qs '^include .*shared/base.mk' $$dir/Makefile; then continue; fi; \
		echo "Entering ${CURDIR}/$$dir"; \
		$(MAKE) tiff -C $$dir || fail=1; \
	done; exit $$fail

missingini:
	@echo "The following tests have no test scripts. They must me run manually..."
	@./Scripts/missingini.sh */*/*/*
	
clean:
	@for dir in $(SUBDIRS); do \
		if grep -qs '^include .*shared/base.mk' $$dir/Makefile; then continue; fi; \
		echo "Cleaning up ${CURDIR}/$$dir"; \
		$(MAKE) -C $$dir clean; \
	done
