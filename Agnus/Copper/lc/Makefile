# Regression testing for vAmiga 
# Version: 2.1.2022
#
# To run all regression tests:
# make [-j<number of parallel threads>]

# Collect all .ini files
INI=$(wildcard */*.ini)
LOG=$(INI:.ini=.log)
TIFF=$(INI:.ini=.tiff)

.PHONY: all prepare clean

all: prepare $(LOG) $(TIFF)
	@echo > /dev/null

prepare:
	@echo "Running regression tests..."
		
clean:
	rm -f */*.log

# Failing tests
lc1/lc1.log lc2/lc2.log lc3/lc3.log:
	@echo "$(basename $@): TODO: Reimplement with synced CPU"
	@echo "$(basename $@): TODO: Reimplement with synced CPU" > $@

%.log: %.tiff
	@cp $(wildcard $(dir $@)*.adf) /tmp/$(basename $(@F)).adf
	@$(VAMIGA) $(basename $@).ini &> /dev/null
	@cmp /tmp/$(basename $(@F)).tiff $(basename $@).tiff
	@echo "$(basename $@): PASS"
	@echo "$(basename $@): PASS" > $@
	@rm /tmp/$(basename $(@F)).adf
	@rm /tmp/$(basename $(@F)).tiff

%.tiff:
	@echo "Creating missing reference image $@"
	@cp $(wildcard $(dir $@)*.adf) /tmp/$(basename $(@F)).adf
	@$(VAMIGA) $(basename $@).ini &> /dev/null
	@cp /tmp/$(basename $(@F)).tiff $(basename $@).tiff
	@rm /tmp/$(basename $(@F)).adf
	@rm /tmp/$(basename $(@F)).tiff
	