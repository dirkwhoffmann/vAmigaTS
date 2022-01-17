SUBDIRS = int
MYMAKE = $(MAKE) --no-print-directory

.PHONY: all subdirs clean

all: subdirs
	@echo > /dev/null
	
prebuild:
	@echo "Entering ${CURDIR}"
		
subdirs:
	@for dir in $(SUBDIRS); do \
		echo "Entering ${CURDIR}/$$dir"; \
		$(MAKE) -C $$dir; \
	done

clean:
	@for dir in $(SUBDIRS); do \
		echo "Cleaning up ${CURDIR}/$$dir"; \
		$(MAKE) -C $$dir clean; \
	done
