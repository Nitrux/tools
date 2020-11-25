# each sed command below specifies contexts in which
# a command is expected to be found.


fn list_cmds @ =
    sed '''
        /^#/d
        s:(:\n:g
        s:{:\n:g
        s:`:\n:g
        s:|:\n:g
        s:&:\n:g
        s:;:\n:g
        s:exec:\n:g
        s:eval:\n:g
        s:^[ \t]*::
        /^$/d
    ''' "$@"
end


# print the binary's path to stdout if it exists.

fn get_path =
    while read f; do
        type "$f" | grep -Eq 'function|builtin' && continue
        which -- "$f" && continue
        test -x "$f"  && put "$f"
    done 2> /dev/null
end

fn execs::main s @ =
    list_cmds "$s" "$@"
    | awk '{ print $1 }'
    | sort -u
    | get_path
end
