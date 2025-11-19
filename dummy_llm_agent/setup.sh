#!/bin/bash

# LLM Agent Setup Script

AGENT_DIR="/home/rocio/Documentos/GHOSTS/dummy_llm_agent"

echo "=========================================="
echo "  GHOSTS LLM Agent - Setup"
echo "=========================================="
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3."
    exit 1
fi

echo "✓ Python version: $(python3 --version)"

# Create virtual environment if it doesn't exist
if [ ! -d "$AGENT_DIR/venv" ]; then
    echo ""
    echo "Creating Python virtual environment..."
    python3 -m venv "$AGENT_DIR/venv"
    echo "✓ Virtual environment created"
fi

# Activate virtual environment
source "$AGENT_DIR/venv/bin/activate"

# Install dependencies
echo ""
echo "Installing Python dependencies..."
pip install -q --upgrade pip
pip install -q -r "$AGENT_DIR/requirements.txt"
echo "✓ Dependencies installed"

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Set your OpenAI API key:"
echo "   export OPENAI_API_KEY='your-api-key-here'"
echo ""
echo "2. Choose an NPC profile (or use default Dr. Sarah Chen):"
echo "   ./switch-npc.sh sarah_chen"
echo "   ./switch-npc.sh marcus_rodriguez"
echo "   ./switch-npc.sh emma_thompson"
echo ""
echo "3. Start the LLM service:"
echo "   ./start-llm-service.sh"
echo ""
echo "4. Start the GHOSTS agent (in another terminal):"
echo "   ./run-agent.sh"
echo ""
