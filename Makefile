# Top-level Makefile for the vAmiga regression test suite
# (C)opyright Dirk W. Hoffmann, 2022

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
