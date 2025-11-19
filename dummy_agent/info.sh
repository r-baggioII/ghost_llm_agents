#!/bin/bash

# Quick Information Script for Dummy Agent

echo "=========================================="
echo "  Dummy Agent - Quick Info"
echo "=========================================="
echo ""

AGENT_DIR="/home/rocio/Documentos/GHOSTS/dummy_agent"

echo "📂 Directory Structure:"
echo "  Agent Root:    $AGENT_DIR"
echo "  Binaries:      $AGENT_DIR/bin/"
echo "  Config:        $AGENT_DIR/config/"
echo "  Workspace:     $AGENT_DIR/workspace/"
echo "  Logs:          $AGENT_DIR/logs/"
echo ""

echo "⚙️  Configuration:"
if [ -f "$AGENT_DIR/bin/config/application.json" ]; then
    API_URL=$(grep -o '"ApiRootUrl": "[^"]*"' "$AGENT_DIR/bin/config/application.json" | cut -d'"' -f4)
    echo "  API Server:    $API_URL"
    echo "  Timeline:      $AGENT_DIR/bin/config/timeline.json"
fi
echo ""

echo "📊 Status:"
if pgrep -f "Ghosts.Client.Universal" > /dev/null; then
    echo "  Agent Status:  ✅ RUNNING"
    PID=$(pgrep -f "Ghosts.Client.Universal")
    echo "  Process ID:    $PID"
else
    echo "  Agent Status:  ⭕ STOPPED"
fi
echo ""

echo "📁 Workspace Contents:"
if [ -d "$AGENT_DIR/workspace" ]; then
    WORKSPACE_FILES=$(find "$AGENT_DIR/workspace" -type f 2>/dev/null | wc -l)
    WORKSPACE_DIRS=$(find "$AGENT_DIR/workspace" -mindepth 1 -type d 2>/dev/null | wc -l)
    echo "  Files:         $WORKSPACE_FILES"
    echo "  Directories:   $WORKSPACE_DIRS"
    
    if [ $WORKSPACE_FILES -gt 0 ]; then
        echo ""
        echo "  Recent files:"
        find "$AGENT_DIR/workspace" -type f -printf "    - %f (%TY-%Tm-%Td %TH:%TM)\n" 2>/dev/null | head -5
    fi
else
    echo "  Workspace is empty"
fi
echo ""

echo "🚀 Quick Commands:"
echo "  Start agent:   cd $AGENT_DIR && ./run-agent.sh"
echo "  View README:   cat $AGENT_DIR/README.md"
echo "  Check workspace: ls -lah $AGENT_DIR/workspace/"
echo "  View logs:     tail -f $AGENT_DIR/bin/logs/*.log"
echo ""
