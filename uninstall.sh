#!/usr/bin/env bash

set -euo pipefail
script_dirpath="$(cd "$(dirname "${0}")" && pwd)"

source "${script_dirpath}/shared-consts.env"

if [ -f "${CONFIG_FILEPATH}" ]; then
    echo "Removing config file '${CONFIG_FILEPATH}'..."
    rm "${CONFIG_FILEPATH}"
    echo "Config file removed"
fi

# Unload existing service if it's running (idempotent)
if launchctl list | grep -q "${PLIST_LABEL}"; then
    echo "Unloading existing service from launchctl..."
    launchctl unload "${PLIST_FILEPATH}"
    echo "Service unloaded"
fi

if [ -f "${PLIST_FILEPATH}" ]; then
    echo "Removing plist file '${PLIST_FILEPATH}'..."
    rm "${PLIST_FILEPATH}"
    echo "Plist file removed"
fi
echo "✅ Uninstallation completed successfully"
