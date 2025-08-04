Go CLI Tool Template
====================

This is a template repository for creating Go CLI tools with the following pre-configured infrastructure:

- **Secure devcontainer** based on Anthropic's Claude Code reference implementation with Go development environment
- **Cobra CLI framework** for building command-line applications
- **Build script** for compiling binaries locally
- **GoReleaser** automation for multi-platform releases
- **GitHub Actions** workflow for automated releases
- **Homebrew tap** integration for easy installation

Getting Started
---------------

### 1. Use this template
Click "Use this template" on GitHub to create a new repository from this template.

### 2. Configure the template

**Automated Configuration (Recommended):**
```bash
./configure.sh
```

This script will prompt you for:
- GitHub username
- Repository name  
- CLI binary name
- Homebrew tap name
- CLI description

It automatically updates all necessary files with your configuration.

**Manual Configuration:**
If you prefer to configure manually:
1. Update the module name in `go.mod` from the template placeholders to your actual module path
2. Update the import paths in `main.go` and other files to match your new module name
3. Customize the CLI name and description in `cmd/root.go`
4. Update `.goreleaser.yaml` with your GitHub username, repository name, and Homebrew tap details
5. Update this README with your project-specific information

### 3. Development

Open the project in VS Code and reopen in the devcontainer when prompted.

#### Secure Development Environment

The devcontainer is based on Anthropic's Claude Code reference implementation and includes:

**Core Tools:**
- **Go development environment** (Go 1.19 via Debian packages)
- **Claude Code CLI** - AI-powered coding assistant
- **Node.js 20** - Base runtime environment
- **Git with Delta** - Enhanced git diffs and version control
- **GitHub CLI** - GitHub integration
- **Zsh with enhancements** - Better shell experience with autosuggestions and syntax highlighting

**Security Features:**
- **Network firewall** - Restricts outbound connections to approved domains only
- **Isolated environment** - Runs with controlled network access
- **Persistent volumes** - Maintains bash history and Claude configuration across container rebuilds

**Approved Network Access:**
- GitHub (for code repositories and releases)
- Go module proxy and checksum database (proxy.golang.org, sum.golang.org)
- Go-related domains (golang.org, go.dev, pkg.go.dev)
- Anthropic APIs (api.anthropic.com, claude.ai)
- NPM registry (for Node.js dependencies)

The firewall automatically blocks all other outbound connections for security.

### 4. Building
Run the build script to compile your CLI tool:
```bash
./build.sh
```

The binary will be created at `build/cli-tool`.

### 5. Testing your CLI
```bash
# Run the default command
./build/cli-tool

# Check version
./build/cli-tool version

# Get help
./build/cli-tool --help
```

Project Structure
-----------------

```
.
├── .devcontainer/          # Secure development container (based on Claude Code reference)
│   ├── devcontainer.json  # Container configuration and VS Code settings
│   ├── Dockerfile         # Container image with Go, Claude Code, and security tools
│   └── init-firewall.sh   # Network security firewall script
├── .github/workflows/      # GitHub Actions workflows
│   └── release.yml        # Automated release workflow
├── cmd/                    # CLI command definitions
│   ├── root.go            # Root command and CLI setup
│   └── version.go         # Example version command
├── build/                 # Built binaries (gitignored)
├── .goreleaser.yaml       # GoReleaser configuration
├── build.sh              # Build script
├── configure.sh          # Automated project configuration script
├── main.go               # Application entry point
├── go.mod                # Go module definition
├── TODO.md               # Manual setup tasks checklist
└── README.md             # This file
```

Adding New Commands
-------------------

To add a new command:

1. Create a new file in the `cmd/` directory (e.g., `cmd/mycommand.go`)
2. Define your command using Cobra's command structure
3. Register it with the root command in the `init()` function

Example:
```go
package cmd

import (
    "fmt"
    "github.com/spf13/cobra"
)

var myCmd = &cobra.Command{
    Use:   "mycommand",
    Short: "Description of my command",
    Run: func(cmd *cobra.Command, args []string) {
        fmt.Println("Hello from my command!")
    },
}

func init() {
    rootCmd.AddCommand(myCmd)
}
```

Releases and Distribution
-------------------------

This template includes automated release management using GoReleaser and GitHub Actions.

### Setting up automated releases

1. **Create a Homebrew tap repository**:
   - Create a new GitHub repository named `homebrew-<your-tap-name>` (e.g., `homebrew-tools`)
   - This will be your Homebrew tap for distributing your CLI tool

2. **Configure GoReleaser**:
   - Edit `.goreleaser.yaml` and replace the placeholder values:
     - `YOUR_GITHUB_USERNAME` → your GitHub username
     - `YOUR_TAP_NAME` → your Homebrew tap name (without the `homebrew-` prefix)
     - `YOUR_REPO_NAME` → your CLI tool repository name

3. **Set up GitHub secrets**:
   - Go to your repository Settings → Secrets and variables → Actions
   - Add a secret named `HOMEBREW_TAP_GITHUB_TOKEN`
   - Generate a GitHub Personal Access Token with `repo` scope and use it as the value
   - This token allows GoReleaser to push to your Homebrew tap repository

4. **Create a release**:
   ```bash
   # Tag a new version (must follow semver)
   git tag v1.0.0
   git push origin v1.0.0
   ```

   The GitHub Actions workflow will automatically:
   - Build binaries for multiple platforms (Linux, macOS, Windows)
   - Create a GitHub release with binaries and checksums
   - Generate release notes from git commits (see Conventional Commits below)
   - Update your Homebrew tap with the new version

### Conventional Commits

GoReleaser automatically generates release notes from your git commit messages. For best results, use [Conventional Commits](https://www.conventionalcommits.org/) format:

```bash
feat: add new command for data processing
fix: resolve issue with file path handling
docs: update installation instructions
chore: update dependencies
```

Common prefixes:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `test:` - Test changes

GoReleaser will:
- Group commits by type in the changelog
- Exclude commits with `docs:` and `test:` prefixes by default
- Generate clean, organized release notes automatically

### Installing via Homebrew

Once set up, users can install your CLI tool with:

```bash
# Add your tap
brew tap <your-username>/<your-tap-name>

# Install your tool
brew install <your-tool-name>
```

### Manual installation

Users can also download pre-built binaries from the [Releases](../../releases) page.
```