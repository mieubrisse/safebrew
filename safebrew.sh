#!/usr/bin/env bash

set -euo pipefail
script_dirpath="$(cd "$(dirname "${0}")" && pwd)"

osascript -e 'display notification "Hello world" with title "test 1" subtitle "sub 1"'
echo "I am safebrew!"
exit 0

source "${script_dirpath}/shared-consts.env"


if ! [ -f "${CONFIG_FILEPATH}" ]; then
    echo "Error: No config file found at: ${CONFI_FILEPATH}" >&2
    exit 1
fi

# Load configuration if it exists
if [[ -f "${script_dirpath}/config" ]]; then
    source "${script_dirpath}/config"
fi

# Configuration with defaults
BACKUP_DIR="${BACKUP_DIR:-${script_dirpath}}"
GIT_REPO_URL="${GIT_REPO_URL:-}"
BREWFILE_NAME="${BREWFILE_NAME:-Brewfile}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-Update Homebrew bundle backup}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    error "Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Check if Git is installed
if ! command -v git &> /dev/null; then
    error "Git is not installed. Please install Git first."
    exit 1
fi

# Create backup directory if it doesn't exist
if [[ ! -d "${BACKUP_DIR}" ]]; then
    log "Creating backup directory: ${BACKUP_DIR}"
    mkdir -p "${BACKUP_DIR}"
fi

cd "${BACKUP_DIR}"

# Initialize Git repository if it doesn't exist
if [[ ! -d ".git" ]]; then
    log "Initializing Git repository"
    git init
    
    # Set up remote if provided
    if [[ -n "${GIT_REPO_URL}" ]]; then
        log "Adding remote origin: ${GIT_REPO_URL}"
        git remote add origin "${GIT_REPO_URL}"
    fi
fi

# Generate the Brewfile
log "Generating Brewfile using 'brew bundle dump'"
if [[ -f "${BREWFILE_NAME}" ]]; then
    log "Removing existing ${BREWFILE_NAME}"
    rm "${BREWFILE_NAME}"
fi

if ! brew bundle dump --file="${BREWFILE_NAME}"; then
    error "Failed to generate Brewfile"
    exit 1
fi

log "Brewfile generated successfully"

# Check if there are any changes to commit
if git diff --quiet "${BREWFILE_NAME}" 2>/dev/null; then
    log "No changes detected in ${BREWFILE_NAME}"
    exit 0
fi

# Add and commit the Brewfile
log "Adding ${BREWFILE_NAME} to Git"
git add "${BREWFILE_NAME}"

log "Committing changes"
git commit -m "${COMMIT_MESSAGE}"

# Push to remote if configured
if git remote get-url origin &> /dev/null; then
    log "Pushing to remote repository"
    if ! git push origin main 2>/dev/null; then
        # Try pushing to master if main doesn't exist
        if ! git push origin master 2>/dev/null; then
            # Set upstream and push
            git push --set-upstream origin main
        fi
    fi
else
    warn "No remote repository configured. Skipping push."
fi

log "Backup completed successfully"
