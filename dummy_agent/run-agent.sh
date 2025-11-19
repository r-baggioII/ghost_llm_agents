#!/bin/bash

# Dummy Agent Runner Script
# This script runs the GHOSTS dummy agent with a dedicated workspace

AGENT_DIR="/home/rocio/Documentos/GHOSTS/dummy_agent"
BIN_DIR="$AGENT_DIR/bin"
WORKSPACE_DIR="$AGENT_DIR/workspace"
LOGS_DIR="$AGENT_DIR/logs"

echo "=========================================="
echo "  GHOSTS Dummy Agent"
echo "=========================================="
echo ""

# Verify .NET is installed
if ! command -v dotnet &> /dev/null; then
    echo "ERROR: .NET is not installed."
    exit 1
fi

echo "✓ .NET version: $(dotnet --version)"
echo "✓ Agent directory: $AGENT_DIR"
echo "✓ Workspace directory: $WORKSPACE_DIR"
echo ""

# Ensure workspace directory exists
mkdir -p "$WORKSPACE_DIR"
mkdir -p "$LOGS_DIR"

echo "Configuration:"
echo "  - API Server: http://localhost:5000/api"
echo "  - Timeline: $BIN_DIR/config/timeline.json"
echo "  - Workspace: $WORKSPACE_DIR"
echo ""

echo "Starting dummy agent..."
echo "Press Ctrl+C to stop"
echo ""
echo "------------------------------------------"
echo ""

# Run the agent from bin directory
cd "$BIN_DIR"
dotnet Ghosts.Client.Universal.dll
