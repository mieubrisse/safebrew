#!/bin/bash
set -euo pipefail
script_dirpath="$(cd "$(dirname "${0}")" && pwd)"

# Build the Go binary
echo "Building Go CLI tool..."
cd "${script_dirpath}"
go build -o build/TEMPLATE_CLI_NAME .

echo "Build complete! Binary available at: ${script_dirpath}/build/TEMPLATE_CLI_NAME"