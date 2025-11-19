# Dummy Agent - GHOSTS Client

This is a self-contained GHOSTS agent configured to work in an isolated environment.

## 📂 Directory Structure

```
dummy_agent/
├── bin/                    # Agent binaries and dependencies
│   ├── Ghosts.Client.Universal.dll
│   ├── config/            # Runtime configuration
│   │   ├── application.json
│   │   └── timeline.json
│   ├── instance/          # Agent instance data (ID, state)
│   └── logs/              # Agent execution logs
│
├── config/                # Configuration templates
│   ├── application.json
│   └── timeline.json
│
├── workspace/             # ⭐ AGENT WORKING DIRECTORY
│   └── (all agent file operations happen here)
│
├── logs/                  # Custom logs directory
│
├── run-agent.sh          # Quick start script
└── README.md             # This file
```

## 🚀 Quick Start

### Run the Agent

```bash
cd /home/rocio/Documentos/GHOSTS/dummy_agent
./run-agent.sh
```

### Or run manually:

```bash
cd /home/rocio/Documentos/GHOSTS/dummy_agent/bin
dotnet Ghosts.Client.Universal.dll
```

## ⚙️ Configuration

### Timeline Configuration

The agent's behavior is defined in `config/timeline.json`. 

**Current configuration:**
- Works in: `/home/rocio/Documentos/GHOSTS/dummy_agent/workspace/`
- Creates test folders and files
- Logs activity with timestamps
- Runs in continuous loop

### API Configuration

The agent connects to the GHOSTS API server at:
- **URL**: `http://localhost:5000/api`
- **WebSocket**: `http://localhost:5000/clientHub`

Edit `config/application.json` to change API settings.

## 📊 What the Agent Does

Current timeline performs these actions in the workspace:

1. **Navigate to workspace** - Changes to dedicated workspace directory
2. **Log startup** - Records agent start time
3. **Create test folder** - Makes `test_folder/` directory
4. **Write activity log** - Creates `activity.log` with timestamp
5. **List workspace** - Shows all files in workspace
6. **Display log** - Outputs activity log content
7. **Find all files** - Lists all files recursively
8. **Loop** - Repeats every ~20 seconds

## 🔧 Customization

### Change Working Directory

Edit `config/timeline.json` and update the `cd` command:

```json
{
  "Command": "cd /your/custom/path && your_command",
  ...
}
```

### Add New Commands

Add new timeline events:

```json
{
  "Command": "cd /home/rocio/Documentos/GHOSTS/dummy_agent/workspace && echo 'Hello World'",
  "CommandArgs": [],
  "DelayAfter": 2000,
  "DelayBefore": 500
}
```

### Change Loop Interval

Adjust `DelayAfter` values in milliseconds:
- `1000` = 1 second
- `5000` = 5 seconds
- `60000` = 1 minute

## 📝 Monitoring

### View Agent Logs

```bash
# Runtime logs
tail -f /home/rocio/Documentos/GHOSTS/dummy_agent/bin/logs/*.log

# Workspace activity
cat /home/rocio/Documentos/GHOSTS/dummy_agent/workspace/test_folder/activity.log
```

### Check Workspace Files

```bash
ls -lah /home/rocio/Documentos/GHOSTS/dummy_agent/workspace/
```

## 🛑 Stop the Agent

Press `Ctrl+C` in the terminal running the agent.

Or kill the process:

```bash
pkill -f "Ghosts.Client.Universal"
```

## 🔍 Troubleshooting

### Agent won't start
- Check that .NET 8.0 is installed: `dotnet --version`
- Verify configuration files exist in `bin/config/`

### Files not appearing in workspace
- Check timeline.json uses correct `cd` command
- Verify workspace directory permissions

### Connection errors (404)
- Normal if API server endpoints are not fully configured
- Agent will continue executing timeline commands

## 📚 Resources

- **GHOSTS Documentation**: https://cmu-sei.github.io/GHOSTS/
- **Project Repository**: https://github.com/cmu-sei/GHOSTS
- **Main Project**: `/home/rocio/Documentos/GHOSTS/`

---

**Status**: ✅ Ready to run
**Agent Type**: Dummy Agent (Testing/Development)
**Workspace**: `/home/rocio/Documentos/GHOSTS/dummy_agent/workspace/`
