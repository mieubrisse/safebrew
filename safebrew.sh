#!/usr/bin/env bash

set -euo pipefail
script_dirpath="$(cd "$(dirname "${0}")" && pwd)"

source "${script_dirpath}/shared-consts.env"

if ! [ -f "${CONFIG_FILEPATH}" ]; then
    echo "Error: Missing config file: ${CONFIG_FILEPATH}" >&2
    exit 1
fi
source "${CONFIG_FILEPATH}"   # We use 'source' so the user can include things like ${HOME}

if ! command -v "${BREW_BINPATH}" &> /dev/null; then
    echo "Error: 'brew' is not installed" >&2
    exit 1
fi

if ! command -v "${GIT_BINPATH}" &> /dev/null; then
    echo "Error: 'git' is not installed" >&2
    exit 1
fi

if [ -z "${GIT_REPO_DIRPATH}" ]; then
    echo "Error: GIT_REPO_DIRPATH must be set" >&2
    exit 1
fi
if ! [ -d "${GIT_REPO_DIRPATH}" ]; then
    echo "Error: GIT_REPO_DIRPATH is '${GIT_REPO_DIRPATH}' which is not a directory" >&2
    exit 1
fi
if ! [ -d "${GIT_REPO_DIRPATH}/.git" ]; then
    echo "Error: GIT_REPO_DIRPATH is '${GIT_REPO_DIRPATH}' which is not a Git repo" >&2
    exit 1
fi

if [ -z "${GIT_BINPATH}" ]; then
    echo "Error: GIT_BINPATH must be set" >&2
    exit 1
fi
if [ -z "${BREW_BINPATH}" ]; then
    echo "Error: BREW_BINPATH must be set" >&2
    exit 1
fi

cd "${GIT_REPO_DIRPATH}"
if ! git remote get-url origin ; then
    echo "Error: Repository '${GIT_REPO_DIRPATH}' doesn't have an origin" >&2
    exit 1
fi

"${GIT_BINPATH}" fetch

"${GIT_BINPATH}" reset --hard origin/HEAD

echo "Dumping brew..."
HOMEBREW_NO_UPDATE=1 "${BREW_BINPATH}" bundle dump -f --file Brewfile

echo "Adding Brewfile..."
"${GIT_BINPATH}" add Brewfile

# We commit regardless so that automation which checks freshness of the rpeo can 
# be sure the pipeline is still running
echo "Committing..."
"${GIT_BINPATH}" commit --allow-empty -m "Automated backup: $(date)"

echo "Pushing..."
"${GIT_BINPATH}" push

echo "✅ Backup complete"
