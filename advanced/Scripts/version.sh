#!/usr/bin/env sh
# Pi-hole: A black hole for Internet advertisements
# (c) 2017 Pi-hole, LLC (https://pi-hole.net)
# Network-wide ad blocking via your own hardware.
#
# Show version numbers
#
# This file is copyright under the latest version of the EUPL.
# Please see LICENSE file for your rights under this license.

# shellcheck source=./advanced/Scripts/utils.sh
. /opt/pihole/utils.sh

# Load the versions file populated by updatechecker.sh
cachedVersions="/etc/pihole/versions"

if [ -f "${cachedVersions}" ]; then
    loadVersionFile "${cachedVersions}"
else
    echo "Could not find /etc/pihole/versions. Running update now."
    pihole updatechecker
    loadVersionFile "${cachedVersions}"
fi

# Convert "null" or empty values to "N/A" for display
normalize_version() {
    if [ -z "${1}" ] || [ "${1}" = "null" ]; then
        echo "N/A"
    else
        echo "${1}"
    fi
}

main() {
    local details
    details=false

    # Automatically show detailed information if
    # at least one of the components is not on master branch
    if [ ! "${CORE_BRANCH}" = "master" ] || [ ! "${WEB_BRANCH}" = "master" ] || [ ! "${FTL_BRANCH}" = "master" ]; then
        details=true
    fi

    if [ "${details}" = true ]; then
        echo "Core"
        echo "    Version is $(normalize_version "${CORE_VERSION}") (Latest: $(normalize_version "${GITHUB_CORE_VERSION}"))"
        echo "    Branch is $(normalize_version "${CORE_BRANCH}")"
        echo "    Hash is $(normalize_version "${CORE_HASH}") (Latest: $(normalize_version "${GITHUB_CORE_HASH}"))"
        echo "Web"
        echo "    Version is $(normalize_version "${WEB_VERSION}") (Latest: $(normalize_version "${GITHUB_WEB_VERSION}"))"
        echo "    Branch is $(normalize_version "${WEB_BRANCH}")"
        echo "    Hash is $(normalize_version "${WEB_HASH}") (Latest: $(normalize_version "${GITHUB_WEB_HASH}"))"
        echo "FTL"
        echo "    Version is $(normalize_version "${FTL_VERSION}") (Latest: $(normalize_version "${GITHUB_FTL_VERSION}"))"
        echo "    Branch is $(normalize_version "${FTL_BRANCH}")"
        echo "    Hash is $(normalize_version "${FTL_HASH}") (Latest: $(normalize_version "${GITHUB_FTL_HASH}"))"
    else
        echo "Core version is $(normalize_version "${CORE_VERSION}") (Latest: $(normalize_version "${GITHUB_CORE_VERSION}"))"
        echo "Web version is $(normalize_version "${WEB_VERSION}") (Latest: $(normalize_version "${GITHUB_WEB_VERSION}"))"
        echo "FTL version is $(normalize_version "${FTL_VERSION}") (Latest: $(normalize_version "${GITHUB_FTL_VERSION}"))"
    fi
}

main
