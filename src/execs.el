#! /bin/bash


use "../lib/execs.el"

case "$1" in
    ( -h | --help )
        put [
            "execs: print the external commands called by a shell script."
            ""
            "usage:"
            "  execs [-h|--help]"
            "  execs <scripts>" ]
        exit;;
esac

execs::main "$@"
