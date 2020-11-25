#! /bin/bash


fn run cmd @ =
    quiet "./$cmd" --appimage-extract
    chmod +x squashfs-root/AppRun
    ./squashfs-root/AppRun "$@"
    rm -rf squashfs-root
end

run "$@"
