# schoolMIPS makefile
# Stanislav Zhelnio, 2017
#
# based on:
#      makefile for MIPSfpga

help:
	$(info make help            - show this message)
	$(info make all             - build all in programs subdirs)
	$(info make clean           - clean all in programs subdirs)
	@true

TOPTARGETS := all clean
PROGRAMS   := $(wildcard */.)

.PHONY: $(TOPTARGETS) $(PROGRAMS)

$(TOPTARGETS): $(PROGRAMS)

$(PROGRAMS):
	echo $(MAKECMDGOALS)
ifeq ($(MAKECMDGOALS), all)
	$(MAKE) -C $@ $(MAKECMDGOALS)
endif
ifeq ($(MAKECMDGOALS), clean)
	$(MAKE) -C $@ $(MAKECMDGOALS)
endif