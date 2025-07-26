class Safebrew < Formula
  desc "Tiny automation system for regularly backing up Homebrew packages to Git"
  homepage "https://github.com/mieubrisse/safebrew"
  url "https://github.com/mieubrisse/safebrew/archive/refs/heads/main.tar.gz"
  version "1.0.0"
  sha256 "c255a80ba6f389de908705d27e828835ef75b6424a887fa7dff0949f06a6c1aa"
  license "MIT"

  def install
    # Install all scripts to libexec to keep them together
    libexec.install Dir["*"]
    
    # Create a wrapper script for the main safebrew command
    (bin/"safebrew").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail
      script_dirpath="#{libexec}"
      exec "#{libexec}/safebrew.sh" "$@"
    EOS
    
    # Create a wrapper script that handles installation
    (bin/"safebrew-install").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail
      script_dirpath="#{libexec}"
      exec "#{libexec}/install.sh" "$@"
    EOS
    
    # Create a wrapper script that handles uninstallation
    (bin/"safebrew-uninstall").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail
      script_dirpath="#{libexec}"
      exec "#{libexec}/uninstall.sh" "$@"
    EOS
    
    # Make the wrapper scripts executable
    chmod 0755, bin/"safebrew"
    chmod 0755, bin/"safebrew-install"
    chmod 0755, bin/"safebrew-uninstall"
  end

  def caveats
    <<~EOS
      To set up automated Homebrew backups:
        1. Run: safebrew-install
        2. Follow the prompts to configure your Git repository

      To run a backup manually:
        safebrew

      To uninstall the automation (but keep this formula):
        safebrew-uninstall
    EOS
  end

  test do
    # Test that the wrapper script exists and is executable
    assert_predicate bin/"safebrew", :exist?
    assert_predicate bin/"safebrew-install", :exist?
    assert_predicate bin/"safebrew-uninstall", :exist?
    
    # Test that safebrew fails gracefully when config is missing (expected behavior)
    output = shell_output("#{bin}/safebrew 2>&1", 1)
    assert_match "Missing config file", output
  end
end