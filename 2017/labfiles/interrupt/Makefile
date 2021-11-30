SRCDIR	= src

NAME	= counter

KOFILE	= $(NAME).ko
COBJ	= $(SRCDIR)/$(NAME)_c.o
SOBJ	= $(SRCDIR)/$(NAME)_S.o

CSRC	= $(SRCDIR)/$(NAME)_c.c
SSRC	= $(SRCDIR)/$(NAME)_S.S

ifneq ($(KERNELRELEASE),)
obj-m  = $(NAME).o
counter-objs := $(SOBJ) $(COBJ)
else
BINDIR	= bin
KDIR	= /lib/modules/$(shell uname -r)/build
all: $(SOBJ)
	${MAKE} -C $(KDIR) M=$(shell pwd) modules
	mv $(KOFILE) $(BINDIR)/$(KOFILE)
	${MAKE} postbuild_clean

$(SOBJ):
	${CC} -c -o $(SOBJ) $(SSRC)


clean: postbuild_clean
	rm -f $(BINDIR)/*

postbuild_clean:
	rm -f $(SRCDIR)/*.o
	$(GLOBIGNORE='check_irq.ko'; rm -f *.ko)
	rm -f *.o *.mod.c .*.o .*.ko .*.mod.c .*.cmd .*.tmp *~
	rm -f Module.symvers Module.markers modules.order
	rm -rf .tmp_versions
endif
