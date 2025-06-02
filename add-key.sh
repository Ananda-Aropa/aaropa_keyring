#!/bin/bash

set -e

if [ -z "$1" ]; then
	echo "Usage: add-key.sh keyfile" >&2
	exit 1
fi

# avoid gnupg touching ~/.gnupg
GNUPGHOME=$(mktemp -d -t jetring.XXXXXXXX)
export GNUPGHOME
trap cleanup exit
cleanup () {
	rm -rf "$GNUPGHOME"
}

keyfile=$(readlink -f "$1") # gpg works better with absolute keyring paths
keydir=keyring

basename=$(basename "$keyfile")
date=`date -R`

keyid=$(gpg --with-colons --keyid long --options /dev/null --no-auto-check-trustdb < $keyfile | grep '^pub' | cut -d : -f 5)

if [ -e $keydir/0x$keyid ]; then
	echo "0x$keyid already exists in $keydir - existing key or error."
	exit 1
fi

gpg --quiet --import $keyfile
gpg --keyring output/keyrings/blisslabs-keyring.pgp --check-sigs --with-fingerprint --keyid-format 0xlong 0x$keyid | \
less

gpg --no-auto-check-trustdb --options /dev/null \
	--keyring output/keyrings/blisslabs-keyring.pgp \
	--export-options export-clean,no-export-attributes \
	--export $keyid > $keydir/0x$keyid
git add $keydir/0x$keyid
