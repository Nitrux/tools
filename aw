#! /bin/sh


set -e

case "$1" in

	-h|--help)

		echo "${0##*/}: Run AppImages in containers."
		echo "Usage: ${0##*/} [-h|--help] [AppImage]"
		exit

	;;

esac

_e () { echo -e "${0##*/}: \e[31mError:\e[0m $@" >&2; exit 1; }




#		Run the command.

test $# -eq 0 &&
	_e "Nothing to wrap."

_app="$1"
shift

./$_app --appimage-extract > /dev/null 2>&1
chmod +x squashfs-root/AppRun
./squashfs-root/AppRun "$@"
rm -rf squashfs-root
