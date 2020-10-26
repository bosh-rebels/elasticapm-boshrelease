#!/bin/bash

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DOWNLOAD_FOLDER="/tmp/bosh_downloads"

APM_SERVER_VERSION="7.9.0"
BLOB_FILENAME="apm-server-$APM_SERVER_VERSION.tar.gz"
APM_SERVER_DOWNLOAD_URL="https://artifacts.elastic.co/downloads/apm-server/apm-server-$APM_SERVER_VERSION-linux-x86_64.tar.gz"

function blob_exists {
    local blob_path=$1

    [[ -f "$blob_path" ]] || return 1
}

if ! blob_exists "$DOWNLOAD_FOLDER/$BLOB_FILENAME"; then
    mkdir -p "$DOWNLOAD_FOLDER"
    curl -L -J -o "$DOWNLOAD_FOLDER/$BLOB_FILENAME" "$APM_SERVER_DOWNLOAD_URL"
    bosh add-blob --dir="$THIS_SCRIPT_DIR" "$DOWNLOAD_FOLDER/$BLOB_FILENAME" "apm-server/$BLOB_FILENAME"
fi