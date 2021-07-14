#! /bin/sh


test $# = 0 && exit 1

cmd="$1"
shift

"./$cmd" --appimage-extract > /dev/null 2>&1
chmod +x squashfs-root/AppRun
./squashfs-root/AppRun "$@"
rm -rf squashfs-root
