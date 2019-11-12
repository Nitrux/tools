pkgname=nitrux-tools

pkgver=123
pkgrel=1

pkgdesc="Tools for building ISO images and other miscellaneous tasks."
arch=("any")

url="https://github.com/nitrux/tools"
license=('unknown')

depends=('xorriso' 'curl' 'grub' 'mtools' 'squashfs-tools' 'jq' 'zsync')
source=("git://github.com/nitrux/tools")

sha1sums=('SKIP')

pkgver () {
	git describe --long --tags | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g'
	echo 123
}

build () { :; }

package () {
	cd $pkgname
	cp [a-z]* $pkgdir
}
