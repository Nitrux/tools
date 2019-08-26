#! /bin/sh

set -e

case "$1" in

	-h|--help)

		echo "${0##*/}: Run AppImages in containers."
		echo "Usage: ${0##*/} [-h|--help] [AppImage]"
		exit

	;;

esac

_e () { printf %b "${0##*/}: \e[31mError:\e[0m $@\n" >&2; exit 1; }

[ $# -eq 0 ] &&
	_e "Nothing to wrap."

NAME="$1"
TMP_DIR=$(mktemp -d)
shift

./$NAME --appimage-extract > /dev/null 2>&1
mv ./squashfs-root/ $TMP_DIR
$TMP_DIR/AppRun $@
