# GHOSTS LLM Agent - Command Logging System

## Overview

The LLM agent automatically logs **every command execution** with comprehensive metadata to help you track NPC behavior, debug issues, and analyze agent performance.

## Log Files

All logs are stored in the `logs/` directory:

### 1. `command_history.jsonl`
- **Format**: JSON Lines (one JSON object per line)
- **Purpose**: Machine-readable, detailed command history
- **Best for**: Parsing with scripts, detailed analysis

**Structure:**
```json
{
  "timestamp": "2025-01-10T14:23:45.123456",
  "npc_name": "Dr. Sarah Chen",
  "npc_role": "AI Research Scientist",
  "command": "cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace && ls -la",
  "working_directory": "/home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace",
  "delay_after": 15,
  "llm_model": "gpt-4o-mini",
  "session_id": "20250110"
}
```

**Fields Explained:**
- `timestamp`: Exact ISO 8601 timestamp when command was generated
- `npc_name`: Full name of the NPC executing the command
- `npc_role`: Professional role/title of the NPC
- `command`: The exact bash command that will be executed
- `working_directory`: The directory where the command will run
- `delay_after`: Seconds to wait after execution (from timeline config)
- `llm_model`: AI model used (`gpt-4o-mini` or `mock`)
- `session_id`: Daily session identifier (YYYYMMDD)

### 2. `command_history.csv`
- **Format**: CSV (Comma-Separated Values)
- **Purpose**: Human-readable, spreadsheet-friendly
- **Best for**: Opening in Excel, LibreOffice, data analysis tools

**Columns:**
```csv
timestamp,npc_name,npc_role,command,working_directory,delay_after,llm_model,session_id
2025-01-10T14:23:45.123456,Dr. Sarah Chen,AI Research Scientist,"cd workspace && ls -la",/home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace,15,gpt-4o-mini,20250110
```

## Viewing Logs

### Quick View Script

The `view-logs.sh` script provides easy log access:

```bash
# Show statistics (default)
./view-logs.sh stats

# View recent 10 commands
./view-logs.sh recent

# View recent 50 commands
./view-logs.sh recent 50

# View commands by specific NPC
./view-logs.sh npc "Dr. Sarah Chen"

# Live tail (watch commands in real-time)
./view-logs.sh tail

# View CSV in tabular format
./view-logs.sh csv

# Export to readable text file
./view-logs.sh export

# Show help
./view-logs.sh help
```

### Manual Inspection

**View raw JSONL:**
```bash
cat logs/command_history.jsonl
```

**View formatted JSON:**
```bash
jq '.' logs/command_history.jsonl
```

**View last 20 commands:**
```bash
tail -n 20 logs/command_history.jsonl | jq '.'
```

**View CSV:**
```bash
column -t -s',' logs/command_history.csv | less -S
```

## Calculating Time Between Commands

### Using jq (from JSONL)

**Calculate time differences:**
```bash
jq -s 'to_entries | 
  map(select(.key > 0) | 
    {
      command: .value.command, 
      prev_time: (.key - 1 | .[].timestamp), 
      curr_time: .value.timestamp
    }
  )' logs/command_history.jsonl
```

**Average delay:**
```bash
jq -s '[to_entries[] | 
  select(.key > 0) | 
  (.value.timestamp | fromdateiso8601) - 
  (.[.key-1].timestamp | fromdateiso8601)
] | add / length' logs/command_history.jsonl
```

## Analysis Examples

### 1. Count Commands by NPC

```bash
jq -r '.npc_name' logs/command_history.jsonl | sort | uniq -c
```

### 2. Find All File Operations

```bash
jq 'select(.command | test("touch|mkdir|rm|mv|cp"))' logs/command_history.jsonl
```

### 3. Commands in Last Hour

```bash
# Get timestamp from 1 hour ago
HOUR_AGO=$(date -u -d '1 hour ago' --iso-8601=seconds)

# Filter commands
jq --arg since "$HOUR_AGO" 'select(.timestamp > $since)' logs/command_history.jsonl
```

### 4. Export to CSV for Specific Date

```bash
jq -r --arg date "20250110" \
  'select(.session_id == $date) | 
  [.timestamp, .npc_name, .command] | 
  @csv' logs/command_history.jsonl > daily_report.csv
```

### 5. Most Common Commands

```bash
jq -r '.command' logs/command_history.jsonl | sort | uniq -c | sort -nr | head -10
```

## Integration with Other Tools

### Python Analysis

```python
import json
from datetime import datetime

# Load all commands
commands = []
with open('logs/command_history.jsonl', 'r') as f:
    for line in f:
        commands.append(json.loads(line))

# Calculate time deltas
for i in range(1, len(commands)):
    prev_time = datetime.fromisoformat(commands[i-1]['timestamp'])
    curr_time = datetime.fromisoformat(commands[i]['timestamp'])
    delta = (curr_time - prev_time).total_seconds()
    print(f"Time between commands: {delta}s")
    print(f"Command: {commands[i]['command']}")
    print()
```

### Pandas DataFrame

```python
import pandas as pd

# Load CSV into DataFrame
df = pd.read_csv('logs/command_history.csv')

# Convert timestamp to datetime
df['timestamp'] = pd.to_datetime(df['timestamp'])

# Calculate time differences
df['time_delta'] = df['timestamp'].diff().dt.total_seconds()

# Statistics
print(df.groupby('npc_name')['command'].count())
print(df['time_delta'].describe())
```

## Log Rotation

Logs grow over time. Here are strategies to manage them:

### Manual Rotation

```bash
# Archive old logs
DATE=$(date +%Y%m%d)
mv logs/command_history.jsonl logs/command_history_$DATE.jsonl
mv logs/command_history.csv logs/command_history_$DATE.csv

# Logs will be recreated automatically
```

### Automated Weekly Rotation

Create `rotate-logs.sh`:
```bash
#!/bin/bash
WEEK=$(date +%Y_week%V)
cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/logs
mv command_history.jsonl archive/command_history_$WEEK.jsonl 2>/dev/null
mv command_history.csv archive/command_history_$WEEK.csv 2>/dev/null
mkdir -p archive
```

Add to crontab:
```bash
0 0 * * 0 /home/rocio/Documentos/GHOSTS/dummy_llm_agent/rotate-logs.sh
```

## Troubleshooting

### Logs Not Being Created

1. **Check LLM service is running:**
   ```bash
   ps aux | grep llm_service
   ```

2. **Check permissions:**
   ```bash
   ls -la logs/
   # Should be writable by your user
   ```

3. **Check for errors:**
   ```bash
   tail -f bin/logs/app.log
   ```

### Missing Timestamps

- Timestamps are generated when commands are **created**, not executed
- If you need execution timestamps, check GHOSTS client logs in `bin/logs/`

### CSV Formatting Issues

- Commands with commas may break CSV parsing
- Use JSONL for complex commands
- Or use `jq` to properly escape CSV

## What's NOT Logged

The LLM service logs **command generation**, but not:
- ❌ Command execution results (stdout/stderr)
- ❌ Exit codes
- ❌ File system changes
- ❌ Network traffic

For complete system monitoring, check:
- **GHOSTS Client Logs**: `bin/logs/app.log`
- **System Logs**: `/var/log/syslog` or `journalctl`
- **Bash History**: `~/.bash_history`

## Advanced: Real-Time Monitoring

### Watch commands as they're generated

```bash
watch -n 1 'tail -n 5 logs/command_history.jsonl | jq -r ".command"'
```

### Alert on specific patterns

```bash
tail -f logs/command_history.jsonl | \
  jq -r 'select(.command | test("rm|delete")) | "⚠️  ALERT: \(.command)"'
```

### Dashboard with tmux

```bash
tmux new-session \; \
  split-window -h \; \
  select-pane -t 0 \; \
  send-keys './view-logs.sh tail' C-m \; \
  select-pane -t 1 \; \
  send-keys 'watch -n 2 ./view-logs.sh stats' C-m
```

## Best Practices

1. **Regular Backups**: Archive logs weekly/monthly
2. **Monitor Disk Space**: Logs can grow large with many NPCs
3. **Use JSONL for Automation**: Easier to parse than CSV
4. **Session IDs**: Group analysis by daily sessions
5. **Time Deltas**: Calculate in post-processing for accuracy

## Quick Reference

| Task | Command |
|------|---------|
| View stats | `./view-logs.sh stats` |
| Recent 20 | `./view-logs.sh recent 20` |
| Live tail | `./view-logs.sh tail` |
| Export report | `./view-logs.sh export` |
| Count total | `wc -l logs/command_history.jsonl` |
| Pretty JSON | `jq '.' logs/command_history.jsonl` |
| Open in Excel | `libreoffice logs/command_history.csv` |
| Search pattern | `jq 'select(.command | test("pattern"))' logs/command_history.jsonl` |

---

**Need help?** Check the main README.md or create an issue.
