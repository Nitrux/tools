#! /bin/sh


set -e
err () { printf "${0##*/}: \e[31mError:\e[0m %s\n" "$*" >&2; exit 1; }


#	run the command.

test $# = 0 && err "nothing to wrap."

cmd="$1"
shift

"./$cmd" --appimage-extract > /dev/null 2>&1
chmod +x squashfs-root/AppRun
./squashfs-root/AppRun "$@"
rm -rf squashfs-root
