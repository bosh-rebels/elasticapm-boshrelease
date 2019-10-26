#!/bin/bash

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function latest_version {
    grep -r '^version: ' releases/apm-server/apm-server-*.yml | awk -F': ' '{print $NF}' | tail -n 1
}

function bump_minor_version {
    local version=$1
    local major_version
    local minor_version

    major_version="$(echo "$version" | awk -F '.' '{print $1}')"
    minor_version="$(echo "$version" | awk -F '.' '{print $2}')"

    echo "$major_version.$(( minor_version + 1 )).0"
}

function main {
    local amp_server_bosh_release_version
    local release_dir
    local tarball

    amp_server_bosh_release_version="$(bump_minor_version "$(latest_version)")"

    release_dir="$THIS_SCRIPT_DIR/releases"
    tarball="apm-server-boshrelease-$amp_server_bosh_release_version.tgz"

    "$THIS_SCRIPT_DIR"/add-blobs.sh
    bosh create-release --name=apm-server --force --version="$amp_server_bosh_release_version" --final --tarball="$release_dir/$tarball"
}

main