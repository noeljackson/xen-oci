.PHONY: all
all:	build

include common.mk

QEMU_SRC := $(abspath qemu-xen)
QEMU_URL ?= https://github.com/edera-dev/qemu.git
QEMU_BRANCH ?= edera

INSTALL_PREFIX ?= /usr

# Xen soures configuration

# reconfigure xen source to build tools differently from xen itself
XEN_CONFIGURE_OPTS ?= --prefix=$(INSTALL_PREFIX) \
		  --disable-xen --enable-tools --disable-stubdom --disable-docs

.PHONY: xen-configure
xen-configure: $(XEN_SRC)
	cd $(XEN_SRC) && ./configure $(XEN_CONFIGURE_OPTS)

TOOL_CFLAGS := -O2 -Wall -static -fPIC
TOOL_LDFLAGS := -static
TOOL_ARGS := all V=1 nosharedlibs=y

XEN_TOOLS := call ctrl devicemodel foreignmemory gnttab guest evtchn \
		 toolcore toollog

# order is important
TOOL_SUBDIRS := tools/include $(addprefix tools/libs/,$(XEN_TOOLS)) tools/ocaml

tools/%: xen-configure
	$(MAKE) EXTRA_CFLAGS_XEN_TOOLS="$(TOOL_CFLAGS)" -j -C $(XEN_SRC)/$@ $(TOOL_ARGS)

.PHONY: xen-tools
xen-tools: $(TOOL_SUBDIRS)
	strip $(XEN_SRC)/tools/ocaml/xenstored/oxenstored

.PHONY: build
build: xen-tools

.PHONY: install
install: build
	cd $(QEMU_SRC) && make install
