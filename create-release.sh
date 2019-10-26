#!/bin/bash

APM_SERVER_BOSH_RELEASE_VERSION="0.1.1"
THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
RELEASE_DIR="$THIS_SCRIPT_DIR/releases"
TARBALL="apm-server-boshrelease-$APM_SERVER_BOSH_RELEASE_VERSION.tgz"

"$THIS_SCRIPT_DIR"/add-blobs.sh

bosh create-release --name=apm-server --force --version="$APM_SERVER_BOSH_RELEASE_VERSION" --final --tarball="$RELEASE_DIR/$TARBALL"
