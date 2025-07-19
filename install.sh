#!/usr/bin/env bash

set -euo pipefail
script_dirpath="$(cd "$(dirname "${0}")" && pwd)"

source "${script_dirpath}/shared-consts.env"

EXAMPLE_CONFIG_FILEPATH="${script_dirpath}/safebrew.env.example"

BACKUP_SCRIPT_FILENAME="safebrew.sh"

STDOUT_LOG_FILEPATH="/tmp/${BACKUP_SCRIPT_FILENAME}.out"
STDERR_LOG_FILEPATH="/tmp/${BACKUP_SCRIPT_FILENAME}.err"

# Sanity checks
backup_script_filepath="${script_dirpath}/${BACKUP_SCRIPT_FILENAME}"
if ! [ -x "${backup_script_filepath}" ]; then
    echo "Error: Backup script is not executable: ${backup_script_filepath}" >&2
    exit 1
fi
if ! [ -d "${LAUNCH_AGENTS_DIRPATH}" ]; then
    # If we don't have LaunchAgents, an assumption is wrong; don't continue
    # because this should already exist
    echo "Error: Couldn't find LaunchAgents diretory: ${LAUNCH_AGENTS_DIRPATH}" >&2
    exit 1
fi

# Prompts the user to fill in the config file from 
fill_config_file() {
    # Use a tempfile for atomicity
    temp_filepath="$(mktemp)"

    comment_buf=()

    echo "✍️ Filling out config: ${CONFIG_FILEPATH}"
    echo ""
    echo "💡 You can use shell syntax, e.g. \$HOME, \"quotes\", etc."
    echo ""

    # Read every line (preserve blanks) from the template
    while IFS= read -r line || [ -n "${line}" ]; do
        case "${line}" in
            \#*)               # Comment (collect for later display)
                comment_buf+=("${line}")
                ;;
            *[A-Za-z0-9_]=*)   # Assignment line (e.g. VAR=)
                var_name="${line%%=*}"           # strip “=...”
                var_name="${var_name//[[:space:]]/}"   # trim stray spaces

                # show the comments that belong to this variable
                if [ ${#comment_buf[@]} -gt 0 ]; then
                    printf "%s\n" "${comment_buf[@]}"
                fi

                # prompt the user
                # We need to explicitly read from /dev/tty because STDIN is already coming from EXAMPLE_CONFIG_FILEPATH
                read -r -p "${var_name}=" value < /dev/tty

                # Write comments + filled-in assignment to the output file
                printf "%s\n" "${comment_buf[@]}"       >>"$temp_filepath"
                printf "%s=%s\n" "$var_name" "$value" >>"$temp_filepath"

                comment_buf=()   # clear buffer for next variable
                echo ""  # Newline in prep for next variable
                ;;
            *)  # anything else, copy through verbatim
                if [ "${#comment_buf[@]}" -gt 0 ]; then
                    printf "%s\n" "${comment_buf[@]}" >>"$temp_filepath"
                fi
                comment_buf=()
                printf "%s\n" "$line"             >>"$temp_filepath"
                ;;
        esac
    done <"$EXAMPLE_CONFIG_FILEPATH"

    cp "${temp_filepath}" "${CONFIG_FILEPATH}"
    echo "✅ Wrote config: ${CONFIG_FILEPATH}"
    echo ""
}

# The user doesn't have a config file; we need to create it for them
if ! [ -f "${CONFIG_FILEPATH}" ]; then
    fill_config_file
fi

# Create a plist file that runs our script
plist_contents="$(cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${PLIST_LABEL}</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>${backup_script_filepath}</string>
    </array>
    
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>12</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    
    <key>StandardOutPath</key>
    <string>${STDOUT_LOG_FILEPATH}</string>
    
    <key>StandardErrorPath</key>
    <string>${STDERR_LOG_FILEPATH}</string>
    
    <key>RunAtLoad</key>
    <false/>
    
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF
)"

# Unload existing service if it's running (idempotent)
if launchctl list | grep -q "${PLIST_LABEL}"; then
    echo "Unloading existing service from launchctl..."
    launchctl unload "${PLIST_FILEPATH}"
fi

echo "${plist_contents}" > "${PLIST_FILEPATH}"

# Load the service (idempotent - launchctl load will succeed even if already loaded)
launchctl load "${PLIST_FILEPATH}"

echo "✅ Installation completed successfully"
echo ""
echo "The backup will run daily at 12:00 PM"
echo "STDOUT logs can be found at ${STDOUT_LOG_FILEPATH}"
echo "STDERR logs can be found at ${STDERR_LOG_FILEPATH}"
echo "You can manually run the backup with: ${backup_script_filepath}"
echo ""
echo "💡 To uninstall, run: ${script_dirpath}"
