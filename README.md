safebrew
========
A tiny automation system for regularly doing `brew bundle dump` and pushing it to a Git repo.

Why this repo?

Automated brew backup is in a curious state. Everybody has the problem - I found multiple blog posts and a couple personal repos - but nobody has an off-the-shelf solution for doing it. Maybe it's considered too small to be worth the time?

But there were enough fiddly bits I had to figure out that I figured I'd publish my solution, so folks don't have to keep reinventing the wheel.


Quick Start
-----------

TODO because it gets sourced, you can use Bash-isms

1. Clone this repository:
   ```bash
   git clone <your-repo-url>
   cd brew-backup
   ```

2. (Optional) Configure your settings:
   ```bash
   cp config.example config
   # Edit config with your preferences
   ```

3. Install the automated backup:
   ```bash
   ./install.sh
   ```

Configuration
-------------

Copy `config.example` to `config` and customize:

- `BACKUP_DIR`: Directory where backups are stored (default: current directory)
- `GIT_REPO_URL`: Git repository URL for pushing backups (optional)
- `BREWFILE_NAME`: Name of the generated Brewfile (default: "Brewfile")
- `COMMIT_MESSAGE`: Commit message for backup commits

Manual Usage
------------

Run a backup manually:
```bash
./backup-brew.sh
```

Scheduled Backups
-----------------

The install script sets up a LaunchAgent that runs daily at 12:00 PM. Logs are written to:
- `/tmp/brew-backup.log` (standard output)
- `/tmp/brew-backup.error.log` (error output)

Uninstall
---------

To remove the automated backup:
```bash
launchctl unload ~/Library/LaunchAgents/BackupHomebrew.plist
rm ~/Library/LaunchAgents/BackupHomebrew.plist
```

Files
-----

- `backup-brew.sh`: Main backup script
- `install.sh`: Installation script for setting up automation
- `com.user.brewbackup.plist`: LaunchAgent configuration
- `config.example`: Configuration template
