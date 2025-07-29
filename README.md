safebrew
========
A tiny automation system for regularly doing `brew bundle dump` to a Git repo, and `git push`ing it.

Why this repo?

Automated Homebrew backup is in an odd state. Everybody has the problem - I found multiple blog posts and several personal repos - but all the solutions are bespoke. Nobody seems to provide an off-the-shelf solution for doing it.

Maybe it's considered too small to be worth the time?

But I figured there was enough complexity to build something generally usable, so here it is.

Prerequisites
-------------
1. `git` and `brew` installed on your machine
1. A Git repo to store your Homebrew backups, cloned somewhere on your machine (e.g. [this is mine](https://github.com/mieubrisse/personal-homebrew-backup))

Installation
------------

### Option 1: Homebrew
1. Install the formula:
   ```
   brew install safebrew.rb
   ```
1. Run the setup:
   ```
   safebrew-install
   ```
1. Follow the prompts to fill in the config values. You can use `$HOME`.

### Option 2: Manual Installation
1. Clone this repo somewhere:
   ```
   git clone git@github.com:mieubrisse/safebrew.git
   ```
1. Run the installation:
   ```
   bash install.sh
   ```
1. Follow the prompts to fill in the config values. You can use `$HOME`.

Usage
-----
A backup will be taken every day at noon.

You can run the backup manually with `safebrew.sh`.

Automated backup logs get written to `/tmp/safebrew.sh.out` and `/tmp/safebrew.sh.err`.

💡 You might want to set up alerting to ensure the backups are still running (e.g. in n8n).

Uninstall
---------
Run the `uninstall.sh` script.
