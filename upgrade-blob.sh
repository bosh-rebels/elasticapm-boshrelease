#!/bin/bash

set -euo pipefail

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PACKAGES_DIR=$THIS_SCRIPT_DIR/packages/apm-server
DOWNLOAD_FOLDER="$THIS_SCRIPT_DIR/.downloads"

APM_SERVER_VERSION=$1
BLOB_FILENAME="apm-server-$APM_SERVER_VERSION.tar.gz"
APM_SERVER_DOWNLOAD_URL="https://artifacts.elastic.co/downloads/apm-server/apm-server-$APM_SERVER_VERSION-linux-x86_64.tar.gz"

function blob_exists {
    local blob_path=$1

    [[ -f "$blob_path" ]] || return 1
    echo "Blob with name $BLOB_FILENAME already exists in $THIS_SCRIPT_DIR/$DOWNLOAD_FOLDER!"
}

function update_packages_version {
  local SED=sed
  unamestr=`uname`
  if [[ "$unamestr" == "Darwin" ]] ; then
    SED=gsed
    type $SED >/dev/null 2>&1 || {
        echo >&2 "$SED it's not installed. Try: brew install gnu-sed" ;
        exit 1;
    }
  fi
  $SED -i "s/[0-9]*\.[0-9]*\.[0-9]*/${APM_SERVER_VERSION}/g" $PACKAGES_DIR/packaging
  $SED -i "s/[0-9]*\.[0-9]*\.[0-9]*/${APM_SERVER_VERSION}/g" $PACKAGES_DIR/spec
}

if ! blob_exists "$DOWNLOAD_FOLDER/$BLOB_FILENAME"; then
    mkdir -p "$DOWNLOAD_FOLDER"
    curl -L -J -o "$DOWNLOAD_FOLDER/$BLOB_FILENAME" "$APM_SERVER_DOWNLOAD_URL"
    echo "Removing old version of apm-server blob..."
    bosh remove-blob "$(bosh blobs | awk -F" " '{print $1}')"
    echo "Adding new version of apm-server blob ${1}"
    bosh add-blob --dir="$THIS_SCRIPT_DIR" "$DOWNLOAD_FOLDER/$BLOB_FILENAME" "apm-server/$BLOB_FILENAME"
    echo "Uploading new apm-server blob ${1} to blobstore..."
    bosh upload-blobs
    update_packages_version
fi
