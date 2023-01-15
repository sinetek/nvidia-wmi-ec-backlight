SHELL := /bin/bash
KVER  ?= $(shell uname -r)
KSRC := /lib/modules/$(KVER)/build
FIRMWAREDIR := /lib/firmware/
PWD := $(shell pwd)
CLR_MODULE_FILES := *.mod.c *.mod *.o .*.cmd *.ko *~ .tmp_versions* modules.order Module.symvers
SYMBOL_FILE := Module.symvers
MODDESTDIR := /lib/modules/$(KVER)/kernel/drivers/platform/x86/

#Handle the compression option for modules in 3.18+
ifneq ("","$(wildcard $(MODDESTDIR)/*.ko.gz)")
COMPRESS_GZIP := y
endif
ifneq ("","$(wildcard $(MODDESTDIR)/*.ko.xz)")
COMPRESS_XZ := y
endif
ifeq ("","$(wildcard MOK.der)")
NO_SKIP_SIGN := y
endif

EXTRA_CFLAGS += -O2

obj-m += nvidia-wmi-ec-backlight.o

.PHONY: all install uninstall clean sign sign-install

all:
	$(MAKE) -C $(KSRC) M=$(PWD) modules
install: all
	@rm -f $(MODDESTDIR)/nvidia-wmi-ec-backlight.ko

	@mkdir -p $(MODDESTDIR)
	@install -p -D -m 644 *.ko $(MODDESTDIR)
ifeq ($(COMPRESS_GZIP), y)
	@gzip -f $(MODDESTDIR)/*.ko
endif
ifeq ($(COMPRESS_XZ), y)
	@xz -f $(MODDESTDIR)/*.ko
endif
	@depmod -a $(KVER)

	@echo "Install nvidia-wmi-ec-backlight SUCCESS"

uninstall:
	@rm -f $(MODDESTDIR)/nvidia-wmi-ec-backlight.ko

	@depmod -a

	@echo "Uninstall nvidia-wmi-ec-backlight SUCCESS"

clean:
	@rm -fr *.mod.c *.mod *.o .*.cmd .*.o.cmd *.ko *~ .*.o.d .cache.mk
	@rm -fr .tmp_versions
	@rm -fr Modules.symvers
	@rm -fr Module.symvers
	@rm -fr Module.markers
	@rm -fr modules.order

