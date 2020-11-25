#! /bin/bash


fn get_manifest name tag =
    curl -fs [
        -H "Authorization: Bearer $access_token"
        -H "Accept: application/vnd.docker.distribution.manifest.v2+json"
        "https://index.docker.io/v2/$name/manifests/$tag" ]
end

fn pull_layers name =
    jq -r .layers[].digest | while read hash; do
        put "downloading '$l'..."
        curl -f -# -OL [
            -H "Authorization: Bearer $access_token"
            -H "Accept: application/vnd.docker.image.rootfs.diff.tar.gzip"
            "https://index.docker.io/v2/$name/blobs/$hash" ]
    done

    for f in *; do
        tar --force-local -xf "$f"
        rm "$f"
    done
end

fn pull::main dir image =
    mkdir -p "$dir"
        || throw "could not create directory '$dir'. aborting."

    cd "$dir"

    var tag img owner = [
        "${image##*:}"
        "${image%%:*}"
        "${img%%/*}" ]

    case "$tag"   in ( '' | "$img" ) var tag = "latest";; esac
    case "$owner" in ( '' | "$img" ) var img = "library/$img";; esac

    put "pulling '$img:$tag'..."

    var access_token = [
        $(curl -sf "https://auth.docker.io/token?service=registry.docker.io&scope=repository:$img:pull"
            | jq -r .token || throw "unable to get an access token.") ]

    get_manifest "$img" "$tag"
        | pull_layers "$img"
end

pull::main "$@"
