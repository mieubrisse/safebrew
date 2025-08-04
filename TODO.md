Manual Setup Tasks
==================

After running `./configure.sh`, complete these manual tasks to enable automated releases and Homebrew distribution.

Required Tasks
--------------

### 1. Create Homebrew Tap Repository

You need to create a separate GitHub repository for your Homebrew tap.

**Steps:**

- [ ] Go to GitHub and create a new repository
- [ ] Name it `homebrew-<your-tap-name>` (e.g., `homebrew-tools`)
- [ ] Make it **public** (Homebrew taps must be public)
- [ ] Initialize with a README (optional)
- [ ] **Do not** add any other files - GoReleaser will manage the Formula

### 2. Generate GitHub Personal Access Token

You need a GitHub Personal Access Token for GoReleaser to push to your Homebrew tap.

**Steps:**

- [ ] Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
- [ ] Click "Generate new token (classic)"
- [ ] Give it a descriptive name like "GoReleaser Homebrew Tap"
- [ ] Set expiration (recommend 1 year or no expiration for automation)
- [ ] Select the following scopes:
  - [ ] `repo` (Full control of private repositories)
  - [ ] `write:packages` (Write packages to GitHub Package Registry)
  - [ ] `read:packages` (Read packages from GitHub Package Registry)
- [ ] Click "Generate token"
- [ ] **Copy the token immediately** (you won't be able to see it again)

### 3. Add GitHub Repository Secret

Add the Personal Access Token as a repository secret.

**Steps:**

- [ ] Go to your CLI tool repository (not the Homebrew tap)
- [ ] Navigate to Settings → Secrets and variables → Actions
- [ ] Click "New repository secret"
- [ ] Name: `HOMEBREW_TAP_GITHUB_TOKEN`
- [ ] Value: Paste the Personal Access Token from step 2
- [ ] Click "Add secret"

### 4. Verify GoReleaser Configuration

Double-check that your `.goreleaser.yaml` file has the correct values after running configure.sh.

**Verify these fields:**

- [ ] `project_name` matches your CLI binary name
- [ ] `binary` matches your CLI binary name
- [ ] `brews.repository.owner` matches your GitHub username
- [ ] `brews.repository.name` matches your Homebrew tap repository name
- [ ] `brews.homepage` has the correct repository URL
- [ ] `brews.description` has your CLI description
- [ ] `brews.test` command uses the correct binary name
- [ ] `brews.install` command uses the correct binary name

Optional Tasks
--------------

### 5. Customize CLI Description and Help Text

Update the CLI help text and descriptions to match your tool's purpose.

**Files to update:**

- [ ] `cmd/root.go` - Update the `Short` and `Long` descriptions
- [ ] `cmd/version.go` - Update the description if needed
- [ ] Add more commands in the `cmd/` directory as needed

### 6. Add License File

Consider adding a license to your project.

**Steps:**

- [ ] Create a `LICENSE` file in your repository root
- [ ] Choose an appropriate license (MIT is common for CLI tools)
- [ ] Update the `license` field in `.goreleaser.yaml` if you choose something other than MIT

### 7. Update README

Customize the README.md for your specific tool.

**Sections to update:**

- [ ] Replace template descriptions with your tool's purpose
- [ ] Add specific installation and usage examples
- [ ] Update the project structure if you add new files
- [ ] Add any additional documentation your users might need

Testing Your Setup
------------------

### Test Local Build

- [ ] Run `./build.sh` to ensure your CLI builds correctly
- [ ] Test your CLI: `./build/<your-cli-name> --help`
- [ ] Test version command: `./build/<your-cli-name> version`

### Test Release Process (Dry Run)

Before creating your first real release, you can test GoReleaser:

- [ ] Install GoReleaser locally: `brew install goreleaser`
- [ ] Run dry-run: `goreleaser release --snapshot --clean`
- [ ] Check the `dist/` directory for generated artifacts

### Create First Release

When everything is working:

- [ ] Commit all your changes: `git add . && git commit -m "feat: initial CLI implementation"`
- [ ] Create and push a tag: `git tag v0.1.0 && git push origin main --tags`
- [ ] Watch the GitHub Actions workflow run
- [ ] Verify the release appears in your GitHub repository
- [ ] Check that your Homebrew tap repository gets updated with a new Formula

Troubleshooting
---------------

### Common Issues

**GoReleaser fails with authentication error:**
- Verify your `HOMEBREW_TAP_GITHUB_TOKEN` secret is set correctly
- Ensure the token has the right permissions (`repo` scope)
- Check that your Homebrew tap repository exists and is public

**Formula not appearing in Homebrew tap:**
- Ensure your Homebrew tap repository name follows the `homebrew-<name>` pattern
- Verify the repository is public
- Check the GoReleaser logs in GitHub Actions for specific errors

**Build fails:**
- Ensure `go mod tidy` has been run
- Verify all import paths in your Go files are correct
- Check that your module name in `go.mod` matches the import paths

### Getting Help

- [ ] Check the [GoReleaser documentation](https://goreleaser.com/)
- [ ] Review the [GitHub Actions logs](../../actions) if releases fail
- [ ] Test locally with `goreleaser release --snapshot --clean`