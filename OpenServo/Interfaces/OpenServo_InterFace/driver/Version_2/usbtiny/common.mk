# ======================================================================
# Common Makefile for USBtiny applications
#
# Macros to be defined before including this file:
#
# USBTINY	- the location of this directory
# TARGET_ARCH	- gcc -mmcu= option with AVR device type
# OBJECTS	- the objects in addition to the USBtiny objects
# FLASH		- command to upload main.hex to flash
# STACK		- maximum stack size
# SCHEM		- Postscript version of the schematic to be generated
#
# Copyright (C) 2006 Dick Streefland
#
# This is free software, licensed under the terms of the GNU General
# Public License as published by the Free Software Foundation.
# ======================================================================

CC	= avr-gcc
CFLAGS	= -Os -g -Wall -I. -I$(USBTINY)
ASFLAGS	= -Os -g -Wall -I.
LDFLAGS	= -g $(LDEXTRAFLAGS)
MODULES = crc.o int.o usb.o $(OBJECTS)
UTIL	= $(USBTINY)/../util

main.hex:

all:		main.hex $(SCHEM)

clean:
	rm -f main.bin *.o tags *.sch~ gschem.log *~

clobber:	clean
	rm -f main.hex $(SCHEM)

main.bin:	$(MODULES)
	$(LINK.o) -o $@ $(MODULES)

main.hex:	main.bin $(UTIL)/check.py
	@$(UTIL)/check.py main.bin $(STACK)
	avr-objcopy -j .text -j .data -O ihex main.bin main.hex
	./checksize main.bin
disasm:		main.bin
	avr-objdump -S main.bin

flash:		main.hex
	$(FLASH)

fuse:
	avrdude -p m8 -U lfuse:w:0x9F:m -U hfuse:w:0xC9:m

crc.o:		$(USBTINY)/crc.S $(USBTINY)/def.h usbtiny.h
	$(COMPILE.c) $(USBTINY)/crc.S
int.o:		$(USBTINY)/int.S $(USBTINY)/def.h usbtiny.h
	$(COMPILE.c) $(USBTINY)/int.S
usb.o:		$(USBTINY)/usb.c $(USBTINY)/def.h $(USBTINY)/usb.h usbtiny.h
	$(COMPILE.c) $(USBTINY)/usb.c

main.o:		$(USBTINY)/usb.h

%.ps:		%.sch $(UTIL)/sch2ps
	$(UTIL)/sch2ps $<
