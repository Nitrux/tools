# routine to copy a binary and its dependencies into a
# directory.


fn copier::main dest src @ =
    mkdir -p "$dest"
        || throw "could not create '$dest'. aborting."

    for f in "$src" "$@"; do
        test -f "$f"
            || throw "file not found '$f'. aborting."
    done

    for f in "$src" "$@"; do
        mkdir -p "$dst/${f%/*}"
        cp -u "$f" "$dst/$f"

        ldd "$f"
        | cut -d " " -f 3
        | grep -vE -e 'dynamic' -e '(^$|:$)'
        | sort -u
        | while read l; do
              mkdir -p "$dest/${l%/*}"
              cp -u "$l" "$dest/$l"
          done
    done
end
