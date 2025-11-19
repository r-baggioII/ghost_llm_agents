#!/bin/bash

# Switch NPC Profile

AGENT_DIR="/home/rocio/Documentos/GHOSTS/dummy_llm_agent"
NPC_DIR="$AGENT_DIR/npc_profiles"

if [ -z "$1" ]; then
    echo "=========================================="
    echo "  Switch NPC Profile"
    echo "=========================================="
    echo ""
    echo "Available NPCs:"
    echo ""
    
    for npc_file in "$NPC_DIR"/*.json; do
        if [[ "$(basename "$npc_file")" != "current_npc.json" ]]; then
            NPC_NAME=$(python3 -c "import json; print(json.load(open('$npc_file'))['name'])" 2>/dev/null || echo "Unknown")
            NPC_ROLE=$(python3 -c "import json; print(json.load(open('$npc_file'))['role'])" 2>/dev/null || echo "Unknown")
            NPC_ID=$(basename "$npc_file" .json)
            echo "  📋 $NPC_ID"
            echo "     Name: $NPC_NAME"
            echo "     Role: $NPC_ROLE"
            echo ""
        fi
    done
    
    echo "Usage: ./switch-npc.sh <npc_id>"
    echo "Example: ./switch-npc.sh sarah_chen"
    exit 0
fi

NPC_ID="$1"
NPC_FILE="$NPC_DIR/${NPC_ID}.json"

if [ ! -f "$NPC_FILE" ]; then
    echo "❌ NPC profile not found: $NPC_ID"
    echo "Run ./switch-npc.sh without arguments to see available NPCs"
    exit 1
fi

# Copy to current_npc.json
cp "$NPC_FILE" "$NPC_DIR/current_npc.json"

NPC_NAME=$(python3 -c "import json; print(json.load(open('$NPC_FILE'))['name'])")
NPC_ROLE=$(python3 -c "import json; print(json.load(open('$NPC_FILE'))['role'])")

echo "✅ NPC Profile switched!"
echo ""
echo "  Name: $NPC_NAME"
echo "  Role: $NPC_ROLE"
echo ""
echo "If the LLM service is running, reload it with:"
echo "  curl -X POST http://localhost:5555/reload-npc"
echo ""
echo "Or restart the service to load the new profile"
