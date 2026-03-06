#! /usr/bin/bash
set -e

cd "$(dirname "$0")"

# Generate changelog (on push)
MSG=$(git log --pretty=format:'  * %h: %s')
DATE=$(git log -1 --pretty=format:'%ad' --date=format:'%a, %d %b %Y %H:%M:%S %z')

cat <<EOF >changelog
${PACKAGE_NAME} ($VERSION-$REVISION) $DISTRO; urgency=medium

$MSG

 -- $MAINTAINER  $DATE

EOF
