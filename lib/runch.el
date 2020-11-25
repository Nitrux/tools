fn mnt inode mp =
    test -e "$inode"
        || throw "'$inode' does not exist."

    mkdir -p "${mp%/*}"

    test -f "$inode" && >> "${mp%/*}"
    test -d "$inode" && mkdir -p "$mp"

    mount -B "$inode" "$mp"
end

fn clean =
    umount -Rf [
        "$dir/proc"
        "$dir/sys"
        "$dir/dev"
        "$dir/run"
        "$dir/tmp"
        "$dir/etc/hosts"
        "$dir/etc/host.conf"
        "$dir/etc/nsswitch.conf"
        "$dir/etc/resolv.conf" ]

    for m in $extra_mnts; do umount -Rf "$dir/${m##*:}"; done
    for d in $_rm_f; do rm -rf "$dir/$d"; done
end

fn runch::main dir cmd @ =
    test $(id -u) -eq 0
        || throw "this program needs root privileges to run."

    test -d "$1"
        || throw "'$1' is not a directory."

    mkdir -p [
        "$dir/proc"
        "$dir/sys"
        "$dir/dev"
        "$dir/run"
        "$dir/tmp" ]

    mount -t proc -o nosuid,noexec,nodev - "$dir/proc"
    mount -t sysfs -o nosuid,noexec,nodev,ro - "$dir/sys"
    mount -t devtmpfs -o mode=0755,nosuid - "$dir/dev"
    mount -t devpts -o mode=0620,gid=5,nosuid,noexec - "$dir/dev/pts"
    mount -t tmpfs -t tmpfs -o mode=1777,nosuid,nodev - "$dir/dev/shm"
    mount -t tmpfs -o mode=1777,strictatime,nodev,nosuid - "$dir/tmp"
    mount -B /run "$dir/run"

    mkdir -p "$dir/etc"

    for f in [
        "/etc/hosts"
        "/etc/host.conf"
        "/etc/nsswitch.conf"
        "/etc/resolv.conf" ]
    do
        test -f "$f" && {
            >> "$dir/$f"
            mount -B "$f" "$dir/$f"
        }
    done

    for dir in $extra_mnts; do
        mnt "${dir%%:*}" "$dir/${dir##*:}"
    done

    trap clean EXIT HUP INT TERM
    chroot $user_spec -- "$dir" "$@"
end
