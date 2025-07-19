#!/bin/bash
set -euo pipefail
script_dirpath="$(cd "$(dirname "${0}")" && pwd)"

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

# Configuration
PLIST_SOURCE="${script_dirpath}/com.user.brewbackup.plist"
PLIST_TARGET="${HOME}/Library/LaunchAgents/BackupHomebrew.plist"
SCRIPT_PATH="${script_dirpath}/backup-brew.sh"


plist_contents=$(cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.brewbackup</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/Users/odyssey/code/brew-backup/backup-brew.sh</string>
    </array>
    
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>12</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    
    <key>StandardOutPath</key>
    <string>/tmp/brew-backup.log</string>
    
    <key>StandardErrorPath</key>
    <string>/tmp/brew-backup.error.log</string>
    
    <key>RunAtLoad</key>
    <false/>
    
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF





# Check if plist file exists
if [[ ! -f "${PLIST_SOURCE}" ]]; then
    error "Plist file not found at ${PLIST_SOURCE}"
    exit 1
fi

# Check if backup script exists and is executable
if [[ ! -f "${SCRIPT_PATH}" ]]; then
    error "Backup script not found at ${SCRIPT_PATH}"
    exit 1
fi

if [[ ! -x "${SCRIPT_PATH}" ]]; then
    log "Making backup script executable"
    chmod +x "${SCRIPT_PATH}"
fi

# Create LaunchAgents directory if it doesn't exist
if [[ ! -d "${HOME}/Library/LaunchAgents" ]]; then
    log "Creating LaunchAgents directory"
    mkdir -p "${HOME}/Library/LaunchAgents"
fi

# Unload existing service if it's running (idempotent)
if launchctl list | grep -q "com.user.brewbackup"; then
    log "Unloading existing service"
    launchctl unload "${PLIST_TARGET}" 2>/dev/null || true
fi

# Update the plist file with the correct script path
log "Updating plist file with correct script path"
sed "s|/Users/odyssey/code/brew-backup/backup-brew.sh|${SCRIPT_PATH}|g" "${PLIST_SOURCE}" > "${PLIST_TARGET}"

# Load the service (idempotent - launchctl load will succeed even if already loaded)
log "Loading backup service"
launchctl load "${PLIST_TARGET}"

log "Installation completed successfully!"
log "The backup will run daily at 12:00 PM"
log "You can manually run the backup with: ${SCRIPT_PATH}"
log "To uninstall, run: launchctl unload ${PLIST_TARGET} && rm ${PLIST_TARGET}"
