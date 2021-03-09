.POSIX:

include config.mk

# Mainly for non-GNU make
SHELL = /bin/sh

BINDIR = ${DESTDIR}${BINPREFIX}
MANDIR = ${DESTDIR}${MANPREFIX}

default: help

install:
	@echo "\033[1mInstalling binary...\033[0m"
	mkdir -p ${BINDIR}
	cp -r neko ${BINDIR}
	chmod 755 ${BINDIR}/neko
	@echo "\033[1mInstalling man page...\033[0m"
	mkdir -p ${MANDIR}
	cp -r neko.1 ${MANDIR}
	chmod 644 ${MANDIR}/neko.1

uninstall:
	@echo "\033[1mRemoving binary...\033[0m"
	rm -rf ${BINDIR}/neko
	@echo "\033[1mRemoving man page...\033[0m"
	rm -rf ${MANDIR}/neko.1

help:
	@echo "Please specify \033[1minstall\033[0m or \033[1muninstall\033[0m option"

.PHONY: default install uninstall help
