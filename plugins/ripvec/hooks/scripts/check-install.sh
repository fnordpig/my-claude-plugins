#!/usr/bin/env bash
# Report ripvec-mcp status. The binary auto-installs via the MCP command
# wrapper (bin/ensure-ripvec-mcp.sh), so this just reports readiness.

set -euo pipefail

if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
	BIN="${CLAUDE_PLUGIN_ROOT}/bin/ripvec-mcp"
else
	BIN="$(cd "$(dirname "$0")/../.." && pwd)/bin/ripvec-mcp"
fi

if [[ -x "$BIN" ]]; then
	VERSION=$("$BIN" --version 2>/dev/null || echo "unknown")
	echo "ripvec-mcp ${VERSION} ready."
else
	echo "ripvec-mcp will auto-install on first use."
fi
