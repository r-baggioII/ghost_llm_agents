# Dummy Agent - Quick Reference

## 🎯 Purpose
Self-contained GHOSTS agent with isolated workspace for testing and development.

## 📦 What's Inside

```
dummy_agent/
├── 🚀 run-agent.sh       → Start the agent
├── ℹ️  info.sh            → Show agent status
├── 📖 README.md          → Full documentation
│
├── bin/                  → Compiled binaries (don't touch)
├── config/               → Configuration templates
├── workspace/            → ⭐ AGENT WORKS HERE ⭐
└── logs/                 → Custom logs
```

## ⚡ Quick Start

```bash
# Start agent
cd /home/rocio/Documentos/GHOSTS/dummy_agent
./run-agent.sh

# Check status
./info.sh

# View workspace
ls -lah workspace/
```

## 🎨 What It Does

The agent performs these actions in a loop:

1. ✅ Changes to `workspace/` directory
2. 📝 Creates `test_folder/`
3. 📄 Writes `activity.log` with timestamp
4. 👀 Lists all workspace files
5. 🔄 Repeats every ~20 seconds

**All file operations happen in:** `workspace/`

## 🛠️ Customization

### Edit Timeline
```bash
nano config/timeline.json
# Then copy to bin/config/
cp config/timeline.json bin/config/
```

### Change Workspace
Edit the `cd` commands in `config/timeline.json`:
```json
"Command": "cd /your/custom/path && your_command"
```

## 📊 Monitoring

```bash
# Live logs
tail -f bin/logs/*.log

# Workspace activity
cat workspace/test_folder/activity.log

# Agent status
./info.sh
```

## 🛑 Stop

```bash
# Press Ctrl+C in agent terminal
# Or kill the process:
pkill -f "Ghosts.Client.Universal"
```

## 🔗 Connections

- **API Server**: http://localhost:5000/api
- **WebSocket**: http://localhost:5000/clientHub
- **Workspace**: `/home/rocio/Documentos/GHOSTS/dummy_agent/workspace/`

---

**Ready to use!** Just run `./run-agent.sh` 🚀
