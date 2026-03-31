#!/usr/bin/env bash
# Verify ripvec and ripvec-mcp are in PATH. Print install instructions if missing.

MISSING=()
command -v ripvec-mcp &>/dev/null || MISSING+=(ripvec-mcp)
command -v ripvec &>/dev/null || MISSING+=(ripvec)

if [[ ${#MISSING[@]} -gt 0 ]]; then
	echo "Missing: ${MISSING[*]}"
	echo ""
	echo "Install with:"
	echo "  cargo install --git https://github.com/fnordpig/ripvec ripvec ripvec-mcp"
	echo ""
	echo "For NVIDIA GPU acceleration (Linux):"
	echo "  cargo install --git https://github.com/fnordpig/ripvec ripvec ripvec-mcp --features cuda"
	echo ""
	echo "Requires Rust toolchain: https://rustup.rs"
	exit 1
fi

VERSION=$(ripvec-mcp --version 2>/dev/null || echo "")
echo "ripvec-mcp${VERSION:+ $VERSION} ready."
