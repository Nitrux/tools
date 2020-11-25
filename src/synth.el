#! /bin/bash


fn setup_base =
    case "$sys_base" in
        ( @URL:* )
            var tmp = $(mktemp)
            wget -qO "$tmp" "${sys_base#@URL:}"
            tar xf "$tmp" -C "$tmp_root";;

        ( @LOCAL:* )
            tar xf "${sys_base#@LOCAL:}" -C "$tmp_root";;

        ( * )  pull "$tmp_root" "$sys_base";;
    esac

    test -x "${input%/*}/preinst" || return 0

    runch [
        -m "${input%/*}/preinst:/preinst"
        -r "/preinst"
        "$tmp_root" "/preinst" ]
end


fn install_pkgs =
    test "$pkgs" || return 0

    case $(which pacman apt apk 2> /dev/null) in
        ( *pacman )
            pm_u="pacman --noconfirm -Syu"
            pm_i="pacman --noconfirm -S";;

        ( *apt )
            pm_u="apt -y upgrade"
            pm_i="apt -y install";;

        ( *apk )
            pm_u="apk update"
            pm_i="apk add";;

        ( * )
            throw "unsupported package manager. aborting.";;
    esac

    runch "$tmp_root" "$pm_u && $pm_i $pkgs"

    test -x "${input%/*}/postinst" || return 0

    runch -m "${input%/*}/postinst:/postinst"    \
          -r "/postinst" "$tmp_root" "/postinst"
end


fn setup_bootloader =
    put "$boot_files" | while IFS=",$IFS" read src sep dest; do
        var dest_path = "${dest%/*}"

        test -e "$src"
            || throw "'$src' does not exist."

        mkdir -p "$tmp_root/$dest_path"
        cp -r "$src" "$tmp_root/$dest"
    done
end


fn get_key key =
    sed -E '''
        :x N
        /,$/ b x
        /[A-Z_][ \t]*$/ b x
        s/,\n[ \t]*/ /g
        s/([A-Z_]+)\n*[ \t]*/\1 /g
        s/[ \t]*->[ \t]*/->/g
    ''' < "synthfile"
    | grep "$key"
    | cut -d " " -f 2-
end

fn main =
    test -r "synthfile" ||
        throw "could not read from 'synthfile'."

    var sys_base hash_url update_url pkgs boot_files bios_boot uefi_boot = [
        $(get_key BASE)
        $(get_key HASH_URL)
        $(get_key UPDATE_URL)
        $(get_key PACKAGES)
        $(get_key BOOT_FILES)
        $(get_key BIOS_BOOT)
        $(get_key UEFI_BOOT) ]

    test "$sys_base"
        || throw "key 'BASE' is empty. aborting."

    trap "rm -rf '$tmp_root' '$iso_dir'" EXIT HUP INT TERM


    #   start the build.

    var img root_sfs tmp_root iso_dir = [
        "${2:-${sys_base}.iso}"
        "rootfs.sfs"
        $(mkdir -p ".rootfs.cache")
        $(mkdir -p ".isodir.cache") ]

       setup_base
    && install_pkgs
    && setup_bootloader


    #   compile the image.

    mksquashfs [
        "$tmp_root"
        "$iso_dir/$root_sfs"
        -b 1M
        -comp xz
        -no-progress ]

    mkiso [
        -u "$update_url"
        -s "$hash_url"
        -r "$sys_release"
        "${bios_boot:+-b}"
        "${uefi_boot:+-e}"
        "$iso_dir"
        "$img" ]

    zsyncmake [
        "$img"
        -u "$update_url"
        -o "$img.zsync" ]

    sha256sum "$img" > "$img.sha256sum"
    md5sum "$img" > "$img.md5sum"

    put "$img"*
end

case "$1" in
    ( -h | --help )
        put [
            "synth: generate the ISO image described in the given file."
            ""
            "usage:"
            "  synth opts  where opts is any option."
            "  synth args  where args are the arguments."
            ""
            "options:"
            "  -h,--help   show this help."
            ""
            "arguments:"
            "  file [img]  given file as input, generate img ISO image."
            "              img is optional; if not passed, it will be derived from file." ]
        exit;;

    ( -* )  throw "unknown option '$1'.";;
esac

main "$@"
