#!/usr/bin/env bash

set -euo pipefail
script_dirpath="$(cd "$(dirname "${0}")" && pwd)"

source "${script_dirpath}/shared-consts.env"

if ! command -v brew &> /dev/null; then
    echo "Error: 'brew' is not installed" >&2
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "Error: 'git' is not installed" >&2
    exit 1
fi

if ! [ -f "${CONFIG_FILEPATH}" ]; then
    echo "Error: Missing config file: ${CONFIG_FILEPATH}" >&2
    exit 1
fi
source "${CONFIG_FILEPATH}"   # We use 'source' so the user can include things like ${HOME}

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

cd "${GIT_REPO_DIRPATH}"
if ! git remote get-url origin ; then
    echo "Error: Repository '${GIT_REPO_DIRPATH}' doesn't have an origin" >&2
    exit 1
fi

echo "Dumping brew..."
brew bundle dump --file Brewfile

echo "Adding Brewfile..."
git add Brewfile

echo "Committing..."
git commit -m "Automated backup: $(date)"

echo "Pushing..."
git push

echo "✅ Backup complete"
