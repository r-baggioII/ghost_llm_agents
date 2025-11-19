#!/bin/bash

# GHOSTS LLM Agent Runner

AGENT_DIR="/home/rocio/Documentos/GHOSTS/dummy_llm_agent"
BIN_DIR="$AGENT_DIR/bin"
WORKSPACE_DIR="$AGENT_DIR/workspace"

echo "=========================================="
echo "  GHOSTS LLM Agent"
echo "=========================================="
echo ""

# Check if LLM service is running
if ! curl -s http://localhost:5555/health > /dev/null 2>&1; then
    echo "⚠️  LLM Service not detected on port 5555"
    echo ""
    echo "Please start the LLM service first:"
    echo "  ./start-llm-service.sh"
    echo ""
    read -p "Continue anyway? (Agent will fail without LLM service) (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    # Get NPC info from service
    NPC_INFO=$(curl -s http://localhost:5555/health | python3 -c "import sys, json; data=json.load(sys.stdin); print(f\"{data.get('npc_name', 'Unknown')} | LLM: {data.get('llm_enabled', False)}\")" 2>/dev/null)
    echo "✓ LLM Service: Online"
    echo "✓ NPC: $NPC_INFO"
fi

# Check .NET
if ! command -v dotnet &> /dev/null; then
    echo "❌ .NET not found"
    exit 1
fi

echo "✓ .NET: $(dotnet --version)"
echo "✓ Workspace: $WORKSPACE_DIR"
echo ""

# Ensure workspace exists
mkdir -p "$WORKSPACE_DIR"

echo "Configuration:"
echo "  - LLM Service: http://localhost:5555"
echo "  - GHOSTS API: http://localhost:5000/api"
echo "  - Workspace: $WORKSPACE_DIR"
echo ""

echo "Starting LLM-powered agent..."
echo "The agent will ask the LLM for the next command every ~15 seconds"
echo "Press Ctrl+C to stop"
echo ""
echo "------------------------------------------"
echo ""

cd "$BIN_DIR"
dotnet Ghosts.Client.Universal.dll
