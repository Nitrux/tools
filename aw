#! /bin/sh


set -e
_e () { printf "${0##*/}: \e[31mError:\e[0m %s\n" "$*" >&2; exit 1; }


case "$1" in
	-h|--help)
		printf "%s\n" \
			"${0##*/}: run AppImages in containers." \
			"" \
			"usage:" \
			"  ${0##*/} [-h|--help]" \
			"  ${0##*/} [AppImage]"
		exit
	;;
esac


#	run the command.

test $# -eq 0 &&
	_e "nothing to wrap."

_app="$1"
shift

./$_app --appimage-extract > /dev/null 2>&1
chmod +x squashfs-root/AppRun
./squashfs-root/AppRun "$@"
rm -rf squashfs-root
