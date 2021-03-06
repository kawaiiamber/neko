# About
`neko` is a WIP package manager written in POSIX shell script and (mostly) POSIX utilities inspired by VOID's `xbps-src` bash script package builder and Gentoo's portage source-based package manager. The command usage and name is inspired by Ataraxia's package manager of the same name (it means "cat" in Japanese 猫). The end goal is to write a package manager using POSIX shell and standard POSIX utilities found in userspaces such as suckless's sbase, GNU's Core Utils, among others (e.g. `id`, `sed`, `cut`, etc). The vision is to make it easy to write templates for like in `xbps-src` and have source based installations like portage from Gentoo.
# Installation
The `makefile` is really more for testing as this is not complete / able to be used, yet. With that in mind, the `install` rule will install the script and man page - `make install`.
## Dependencies
* POSIX shell (e.g. dash, mksh, bash, zsh)
* POSIX utilities (e.g. cd, ln, mkdir, etc)
* GNU wget
* GNU tar
# Usage
Start with copying the included templates to the directory where builds are done - `./neko init`. Then, try building one of the packages - `./neko pkg <pkg-name>`.
# Packages
Very similarly to VOID's package builder, `xbps-src`, every package has it's own folder in `srcpkgs` defined by its `template` file, which gives information on how to build, where to get the source, et cetera. For an example, `neko pkg st` will build based off of `srcpkgs/st/template`:
```
pkgname="st"
short_desc="Simple terminal"
version="0.8.4"
revision="1"
distfiles="https://dl.suckless.org/st/st-${version}.tar.gz"
build_style="makefile"
license="MIT"
license_file="LICENSE"
```
## Steps
Every package will go through these steps:
```
neko_prepare - prepare the enviornment for building the package and get the info from the template
neko_fetch   - get the source (currently using wget)
neko_extract - extract the source (if not using a git build)
neko_patch   - apply patches in srcpkgs/<pkgname>/patches
neko_build   - build the package
```
Those are the steps for `neko pkg <pkgname>`. If installing via `neko em <pkgname>`, the process will also invoke `neko_install`, which installs the package.
## Making a package
A quick way to make a new package is `./neko new <pkg-name>` for testing.
To make a new package for pull request, make a directory in `srcpkgs` with the `<pkgname>` - i.e. `mkdir -p srcpkgs/<pkgname>`. Then, write a file `srcpkgs/<pkgname>/template` with the following content:
```
pkgname            - the name of the package
short_desc         - short description - from the man page, README, repo, summary
version            - the version of the package (if applicable / not a git build)
revision           - changes / updates to the template without changing the version, always starts at 1
distfiles / giturl - the link to the source archive or the link to the git repo
build_style        - the way to build the package (see Build Styles section)
license            - the license that the software is released under
```
### Build Styles
Projects very often contain similar steps to build, so `build_style` is meant to simplify the process. At the moment, there are three Build Styles available that do the following at the `neko_build` phase:
```
makefile:
	make ${make_build_args}
configure:
	./configure ${configure_args}
	make ${make_build_args}
meson:
	meson build
	ninja -C build
```
These steps can be over-written in the template, as well, if the upstream package has different instructions. For example, the `bearssl` and `mksh` templates:
```
pkgname="bearssl"
short_desc="Implementation of the SSL/TLS protocol (RFC 5246) written in C"
version="0.6"
revision="1"
distfiles="https://bearssl.org/bearssl-${version}.tar.gz"
build_style="makefile"

do_install()
{
	neko_pkg install bin build/brssl
	neko_pkg install lib libbearssl.so
	neko_pkg install lib libbearssl.a
}

bearssl_devel_pkg()
{
	pkgname="bearssl-devel"
	short_desc="bearssl - developement files"
	do_install()
	{
		for file in inc/*
		do
			pkg_install inc "${file}"
		done
		pkg_install lib "*.so*"
		pkg_install lib "*.a"
	}
}
```
```
pkgname="mksh"
short_desc="MirBSD Korn shell"
version="R59c"
revision="1"
distfiles="http://www.mirbsd.org/MirOS/dist/mir/mksh/mksh-${version}.tgz"
wrksrc="mksh"
license="custom"
license_file="${files_dir}/TaC-mksh.txt"

do_build()
{
	sh ./Build.sh -r
}

do_install()
{
	pkg_install bin mksh
	pkg_install man mksh.1
	mv dot.mkshrc .mkshrc
	pkg_install conf .mkshrc /skel
}
```
These build styles will try and use `bmake` and `tcc` by default. If GNU `make` is needed, there are `gnu-configure` and `gnu-makefile` build styles. If `gcc` or another `CC` is needed, one can add a `CC="<c-compiler>". For example, the `musl` template:
```
pkgname="musl"
short_desc="Implementation of the standard C library"
version="1.1.24"
revision="1"
distfiles="https://musl-libc.org/releases/musl-${version}.tar.gz"
build_style="gnu-configure"
CC="gcc"
```
# Contributing
For contributing to the shell script, shellcheck is used to ensure portability. Please try and use only POSIX utilities (at the moment `wget` and `tar` are the only non-standard utilities as far as I know). When making a pull request, please make a branch with a relavent name and request to merge to the `develop` branch, unless you're making a pull request for a new package.
## Packages
**PACKAGES MUST:**
* Be able to be built against musl libc libraries
* Be able to be built against bearssl libraries

I strongly push for packages to:
* Adhere to XDG specifications (e.g. not filling up your `$HOME` folder)
* Try and be compiled with TCC (if possible) to save time on compiling

As for how to contribute, it's similar to VOID.
I love the way VOID handles pull requests for new packages, so we'll follow. When pull requesting for packages, request to merge with the master branch.
### New packages
For a new package, there should only be one commit per package with the commit message: `New package: <pkgname>-<version>`. If you're requesting a git build, please attach `-git` to the end of the package name (`srcpkgs/<pkgname>-git/template` will have `pkgname=<pkgname>-git`) with the commit message: `New package: <pkgname>-git`.
### Updating packages
For updating a package, please have the commit message be: `<pkgname>: update to <version>`.
### Patches
This is how I would recommend doing patches. Make two directories, `a` and `b`, then copy the file / files you want to patch to both. Edit the file / files in `b`. Then, `diff -Naur a/<file> b/<file> > <patch-name>.patch`. Then make a directory in `srcpkgs/<pkgname>` called `patches` and put it in there.
# Authors
* CheetahPixie
* KawaiiAmber
# TODO
* Add more build styles / packages
* Find a POSIX way to replace the `wget` solution for `neko_fetch`
