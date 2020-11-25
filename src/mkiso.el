#! /bin/bash


fn main src img =
    test -d "$src"
        || throw "'$src' is not a directory. aborting."

    test "$config_files" && {
        mkdir -p "$iso_dir/boot/grub"
        cp $config_files "$iso_dir/boot/grub"
    }

    test "$themes" && {
        mkdir -p "$iso_dir/boot/grub/themes"
        cp -r $themes "$iso_dir/boot/grub/themes"
    }

    {
        put "HASH_URL $hash_url"
        put "UPDATE_URL $update_url"
        put "RELEASE $release"
    } >> "$iso_dir/.INFO"


    #   generate the bootloader images.

    test "$bios" = y && {
        grub-mkimage [
            -O i386-pc-eltorito
            -o "$iso_dir/bios.img"
            -p /boot/grub

            biosdisk boot linux search normal configfile
            part_gpt btrfs ext2 fat iso9660 loopback test
            keystatus gfxmenu regexp probe all_video gfxterm
            font echo read ls cat png jpeg halt reboot
        ]

        var bios_opts = """
            -eltorito-alt-boot
            -b bios.img
            -no-emul-boot
            -graft-points bios.img=$iso_dir/bios.img
            -boot-load-size 4
            -boot-info-table
            -c boot.cat
            --grub2-boot-info
            --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img
        """
    }


    test "$uefi" = y && {
        var efi_img = $(mktemp)

        grub-mkimage [
            -O x86_64-efi
            -o "$efi_img"
            -p /boot/grub

            efi_gop efi_uga boot linux search normal configfile
            part_gpt btrfs ext2 fat iso9660 loopback test
            keystatus gfxmenu regexp probe all_video gfxterm
            font echo read ls cat png jpeg halt reboot
        ]

        export MTOOLS_SKIP_CHECK=1
        mkfs.vfat [
            -C "$iso_dir/efi.img"
            $(($(wc -c < $efi_img) / 1024 + 511)) ]

        mmd [
            -i "$iso_dir/efi.img"
            efi efi/boot ]

        mcopy [
            -i "$iso_dir/efi.img"
            "$efi_img"
            "::efi/boot/bootx64.efi" ]

        var uefi_opts = """
            -eltorito-alt-boot
            -no-emul-boot
            -e efi.img
            -graft-points efi.img=$iso_dir/efi.img
            -append_partition 2 0xef $iso_dir/efi.img
        """
    }

    #   generate the ISO image.

    xorriso [
        -as mkisofs
        -iso-level 3
        -full-iso9660-filenames
        -volid "$label"
        -o "$output"
        "$iso_dir"
        $bios_opts
        $uefi_opts ]
end

while :; do
    case "$1" in
        ( -V )
            label="$2"
            shift 2;;

        ( -g )
            config_files="$config_files $2"
            shift 2;;

        ( -t )
            themes="$themes $2"
            shift 2;;

        ( -u )
            update_url="$2"
            shift 2;;

        ( -s )
            hash_url="$2"
            shift 2;;

        ( -r )
            release="$2"
            shift 2;;

        ( -b )
            bios=y
            shift;;

        ( -e )
            uefi=y
            shift;;

        ( -d | --debug )
            shift
            set -x;;

        ( -h | --help )
            put [
                "mkiso: generate an ISO image."
                ""
                "usage:"
                "  mkiso [-h|--help] show this help."
                "  mkiso [options] <dir> <img>"
                ""
                "options:"
                "  -d, --debug    enable debugging messages."
                "  -b             enable BIOS support."
                "  -e             enable UEFI support."
                "  -V label       use label as filesystem label."
                "  -g file        use file as a GRUB configuration file."
                "  -t path        use path as a GRUB theme."
                "  -u update_url  znx's update_url."
                "  -s hash_url    znx's hash_url."
                "  -r release     znx's release." ]
            exit;;

        ( -* )    throw "unknown option '$1'.";;
        ( * )     break;;
    esac
done

main "$@"
