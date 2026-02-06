export NPROC ?= $(shell nproc)
export ARCH := $(subst x86_64,i386,$(shell arch))

export XEN_VERSION ?= 4.21
XEN_URL ?= https://github.com/edera-dev/xen.git
XEN_BRANCH ?= edera/$(XEN_VERSION)

export XEN_SRC := $(abspath xen)

$(XEN_SRC):
	git clone -b $(XEN_BRANCH) $(XEN_URL) $@

