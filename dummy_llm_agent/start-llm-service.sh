#!/bin/bash

# Start LLM Decision Service

AGENT_DIR="/home/rocio/Documentos/GHOSTS/dummy_llm_agent"

echo "=========================================="
echo "  Starting LLM Decision Service"
echo "=========================================="
echo ""

# Check if API key is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  WARNING: OPENAI_API_KEY not set!"
    echo "   Service will run in MOCK MODE (predefined commands)"
    echo ""
    echo "   To use real OpenAI integration:"
    echo "   export OPENAI_API_KEY='your-key-here'"
    echo ""
    read -p "Continue in mock mode? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Activate virtual environment
if [ -d "$AGENT_DIR/venv" ]; then
    source "$AGENT_DIR/venv/bin/activate"
else
    echo "❌ Virtual environment not found. Run ./setup.sh first"
    exit 1
fi

# Check current NPC
if [ -f "$AGENT_DIR/npc_profiles/current_npc.json" ]; then
    NPC_NAME=$(python3 -c "import json; print(json.load(open('$AGENT_DIR/npc_profiles/current_npc.json'))['name'])")
    echo "🤖 Active NPC: $NPC_NAME"
else
    echo "⚠️  No NPC profile loaded"
fi

echo ""
echo "Starting service on http://localhost:5555"
echo "Press Ctrl+C to stop"
echo ""

cd "$AGENT_DIR"
python3 llm_service.py
