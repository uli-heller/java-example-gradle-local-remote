#!/bin/sh
#
D="$(dirname "$0")"
D="$(realpath "${D}")"

MAVEN_REPOSITORY="${D}/maven-repository"
MAVEN_REPOSITORY_URL="file://${MAVEN_REPOSITORY}"

rm -rf "${MAVEN_REPOSITORY}"
"${D}/create-version.sh" hello-world 0.8.0 0.9.0 0.9.1
