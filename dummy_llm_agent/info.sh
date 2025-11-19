#!/bin/bash

# Quick Info Script

AGENT_DIR="/home/rocio/Documentos/GHOSTS/dummy_llm_agent"

echo "=========================================="
echo "  GHOSTS LLM Agent - Status"
echo "=========================================="
echo ""

# Check LLM Service
echo "🤖 LLM Service:"
if curl -s http://localhost:5555/health > /dev/null 2>&1; then
    STATUS=$(curl -s http://localhost:5555/health)
    NPC_NAME=$(echo "$STATUS" | python3 -c "import sys, json; print(json.load(sys.stdin).get('npc_name', 'Unknown'))" 2>/dev/null)
    LLM_ENABLED=$(echo "$STATUS" | python3 -c "import sys, json; print('✅ Enabled' if json.load(sys.stdin).get('llm_enabled') else '⚠️  Mock Mode')" 2>/dev/null)
    
    echo "  Status: ✅ Running (http://localhost:5555)"
    echo "  NPC: $NPC_NAME"
    echo "  OpenAI: $LLM_ENABLED"
else
    echo "  Status: ⭕ Not Running"
    echo "  Start with: ./start-llm-service.sh"
fi

echo ""

# Check GHOSTS Agent
echo "🎭 GHOSTS Agent:"
if pgrep -f "Ghosts.Client.Universal" > /dev/null 2>&1; then
    PID=$(pgrep -f "Ghosts.Client.Universal")
    echo "  Status: ✅ Running (PID: $PID)"
else
    echo "  Status: ⭕ Not Running"
    echo "  Start with: ./run-agent.sh"
fi

echo ""

# Current NPC
echo "👤 Active NPC Profile:"
if [ -f "$AGENT_DIR/npc_profiles/current_npc.json" ]; then
    NPC_NAME=$(python3 -c "import json; data=json.load(open('$AGENT_DIR/npc_profiles/current_npc.json')); print(data['name'])" 2>/dev/null)
    NPC_ROLE=$(python3 -c "import json; data=json.load(open('$AGENT_DIR/npc_profiles/current_npc.json')); print(data['role'])" 2>/dev/null)
    NPC_PERSONALITY=$(python3 -c "import json; data=json.load(open('$AGENT_DIR/npc_profiles/current_npc.json')); print(data['personality'])" 2>/dev/null)
    
    echo "  Name: $NPC_NAME"
    echo "  Role: $NPC_ROLE"
    echo "  Personality: $NPC_PERSONALITY"
    echo ""
    echo "  Switch NPC: ./switch-npc.sh"
else
    echo "  No NPC loaded"
fi

echo ""

# Workspace
echo "📁 Workspace Activity:"
WORKSPACE="$AGENT_DIR/workspace"
if [ -d "$WORKSPACE" ]; then
    FILE_COUNT=$(find "$WORKSPACE" -type f 2>/dev/null | wc -l)
    DIR_COUNT=$(find "$WORKSPACE" -mindepth 1 -type d 2>/dev/null | wc -l)
    
    echo "  Location: $WORKSPACE"
    echo "  Files: $FILE_COUNT"
    echo "  Directories: $DIR_COUNT"
    
    if [ $FILE_COUNT -gt 0 ]; then
        echo ""
        echo "  Recent files:"
        find "$WORKSPACE" -type f -printf "    %p\n" 2>/dev/null | head -5
    fi
else
    echo "  Workspace not created yet"
fi

echo ""

# API Key Status
echo "🔑 OpenAI API:"
if [ -n "$OPENAI_API_KEY" ]; then
    KEY_PREFIX=$(echo "$OPENAI_API_KEY" | cut -c1-10)
    echo "  Status: ✅ Set (${KEY_PREFIX}...)"
else
    echo "  Status: ⚠️  Not set (will use mock mode)"
    echo "  Set with: export OPENAI_API_KEY='your-key'"
fi

echo ""
echo "=========================================="
echo "  Quick Commands"
echo "=========================================="
echo ""
echo "  Setup:           ./setup.sh"
echo "  Start LLM:       ./start-llm-service.sh"
echo "  Start Agent:     ./run-agent.sh"
echo "  Switch NPC:      ./switch-npc.sh"
echo "  View README:     cat README.md"
echo "  Test LLM:        curl http://localhost:5555/next-command"
echo ""
