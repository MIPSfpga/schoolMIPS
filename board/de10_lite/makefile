
PWD = $(shell pwd)
PROJECT_PATH = $(PWD)/project

BOARD_NAME = de10_lite

all: \
	clean \
	create \
	build

create:
	mkdir -p $(PROJECT_PATH)
	cp $(PWD)/*.qpf $(PROJECT_PATH)
	cp $(PWD)/*.qsf $(PROJECT_PATH)
	cp $(PWD)/*.sdc $(PROJECT_PATH)

clean:
	rm -rf $(PROJECT_PATH)

open:
	cd $(PROJECT_PATH) && quartus $(BOARD_NAME).qpf &

build:
	cd $(PROJECT_PATH) && quartus_sh --flow compile $(BOARD_NAME)
