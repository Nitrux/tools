#! /bin/bash


while :; do
    case "$1" in
        ( -m )
            var extra_mnts = "$extra_mnts $2"
            shift 2;;

        ( -u )
            var user_spec = "--userspec=$2"
            shift 2;;

        ( -r )
            var _rm_f = "$_rm_f $2"
            shift 2;;

        ( -d | --debug )
            shift
            set -x;;

        ( -h | --help )
            put [
                "runch: run commands in a chroot environment."
                ""
                "usage:"
                "  runch opts dir cmd args  where opts are any options, dir is the chroot directory,"
                "                           cmd is the command to be ran, and args are any arguments"
                "                           to pass to the command."
                ""
                "options:"
                "  -h, --help       show this help."
                "  -d, --debug      enable debugging messges."
                "  -m src:mnt       mount src as mnt relative to the chroot directory."
                "  -u user[:group]  run cmd as the specified user and group id."
                "  -r file          on exit, remove file from the chroot directory." ]
            exit;;

        ( -* ) throw "unknown option '$1'.";;
        ( * )  break;;
    esac
done

runch::main "$@"
