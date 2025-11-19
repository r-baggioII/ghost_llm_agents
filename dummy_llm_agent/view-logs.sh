#!/bin/bash

# GHOSTS LLM Agent - Log Viewer
# View and analyze command execution logs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
JSONL_LOG="$LOG_DIR/command_history.jsonl"
CSV_LOG="$LOG_DIR/command_history.csv"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         GHOSTS LLM Agent - Command Log Viewer         ║${NC}"
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo ""

# Check if logs exist
if [ ! -f "$JSONL_LOG" ] && [ ! -f "$CSV_LOG" ]; then
    echo -e "${YELLOW}⚠️  No command logs found yet.${NC}"
    echo -e "${YELLOW}   Logs will be created when the agent executes commands.${NC}"
    echo ""
    echo -e "${BLUE}📍 Log locations:${NC}"
    echo -e "   • JSONL: $JSONL_LOG"
    echo -e "   • CSV:   $CSV_LOG"
    exit 0
fi

# Function to show log statistics
show_stats() {
    echo -e "${GREEN}📊 Log Statistics:${NC}"
    if [ -f "$JSONL_LOG" ]; then
        local total_commands=$(wc -l < "$JSONL_LOG")
        echo -e "   • Total commands executed: ${YELLOW}$total_commands${NC}"
        
        # Get unique NPCs
        local npcs=$(jq -r '.npc_name' "$JSONL_LOG" 2>/dev/null | sort -u | tr '\n' ', ' | sed 's/,$//')
        echo -e "   • NPCs active: ${CYAN}$npcs${NC}"
        
        # Get time range
        local first_time=$(head -n1 "$JSONL_LOG" | jq -r '.timestamp' 2>/dev/null)
        local last_time=$(tail -n1 "$JSONL_LOG" | jq -r '.timestamp' 2>/dev/null)
        echo -e "   • First command: ${BLUE}$first_time${NC}"
        echo -e "   • Last command:  ${BLUE}$last_time${NC}"
    fi
    echo ""
}

# Function to show recent commands
show_recent() {
    local count=${1:-10}
    echo -e "${GREEN}📜 Recent Commands (last $count):${NC}"
    echo ""
    
    if [ -f "$JSONL_LOG" ]; then
        tail -n "$count" "$JSONL_LOG" | jq -r '
            "[\(.timestamp)] \(.npc_name) (\(.npc_role))\n" +
            "  📁 \(.working_directory)\n" +
            "  💻 \(.command)\n" +
            "  ⏱️  Delay after: \(.delay_after)s\n"
        '
    fi
}

# Function to show commands by NPC
show_by_npc() {
    local npc_name="$1"
    echo -e "${GREEN}👤 Commands by $npc_name:${NC}"
    echo ""
    
    if [ -f "$JSONL_LOG" ]; then
        jq -r "select(.npc_name == \"$npc_name\") | 
            \"[\(.timestamp)] \(.command)\"" "$JSONL_LOG"
    fi
    echo ""
}

# Function to export to readable format
export_readable() {
    local output_file="$LOG_DIR/commands_readable_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "GHOSTS LLM Agent - Command History Report" > "$output_file"
    echo "Generated: $(date)" >> "$output_file"
    echo "==========================================" >> "$output_file"
    echo "" >> "$output_file"
    
    if [ -f "$JSONL_LOG" ]; then
        jq -r '
            "Timestamp: \(.timestamp)\n" +
            "NPC: \(.npc_name) (\(.npc_role))\n" +
            "Working Directory: \(.working_directory)\n" +
            "Command: \(.command)\n" +
            "Delay After: \(.delay_after)s\n" +
            "Model: \(.llm_model)\n" +
            "Session: \(.session_id)\n" +
            "---\n"
        ' "$JSONL_LOG" >> "$output_file"
    fi
    
    echo -e "${GREEN}✅ Exported to: $output_file${NC}"
}

# Main menu
case "${1:-stats}" in
    stats)
        show_stats
        ;;
    recent)
        show_stats
        show_recent "${2:-10}"
        ;;
    npc)
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Please specify NPC name${NC}"
            echo "Usage: $0 npc \"Dr. Sarah Chen\""
            exit 1
        fi
        show_by_npc "$2"
        ;;
    export)
        export_readable
        ;;
    tail)
        echo -e "${GREEN}📡 Live tail (Ctrl+C to stop):${NC}"
        echo ""
        tail -f "$JSONL_LOG" | while read line; do
            echo "$line" | jq -r '
                "[\(.timestamp)] \(.npc_name): \(.command)"
            ' 2>/dev/null || echo "$line"
        done
        ;;
    csv)
        if [ -f "$CSV_LOG" ]; then
            column -t -s',' "$CSV_LOG" | less -S
        else
            echo -e "${RED}❌ CSV log not found${NC}"
        fi
        ;;
    help|*)
        echo -e "${BLUE}Usage:${NC}"
        echo "  $0 stats              - Show log statistics (default)"
        echo "  $0 recent [N]         - Show recent N commands (default 10)"
        echo "  $0 npc \"Name\"         - Show commands by specific NPC"
        echo "  $0 tail               - Live tail of commands"
        echo "  $0 export             - Export to readable text file"
        echo "  $0 csv                - View CSV log (tabular)"
        echo "  $0 help               - Show this help"
        echo ""
        echo -e "${BLUE}Examples:${NC}"
        echo "  $0 recent 20"
        echo "  $0 npc \"Dr. Sarah Chen\""
        echo "  $0 tail"
        ;;
esac
