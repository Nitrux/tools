#! /bin/bash


use "../lib/copier.el"

case "$1" in
    ( -h | --help )
        put [
            "copier: copy binaries and their dependencies to a directory."
            "the list of binaries will be read from stdin."
            ""
            "usage:"
            "  copier [-h|--help]  show this help."
            "  copier <dir>" ]
        exit;;

    ( -d | --debug )
        shift
        set -x;;
esac

copier::main "$@"
