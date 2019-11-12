pkgname=tools

pkgver=1
pkgrel=1

pkgdesc="Tools for building ISO images and other miscellaneous tasks."
arch=("any")

url="https://github.com/nitrux/tools"
license=('unknown')

depends=('libisoburn' 'curl' 'grub' 'mtools' 'squashfs-tools' 'jq' 'zsync')
source=("git://github.com/nitrux/tools")

sha1sums=('SKIP')

build () { :; }

package () {
	cd tools
	cp [a-z]* $pkgdir
}
