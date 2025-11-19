# GHOSTS LLM Agent

An intelligent GHOSTS agent powered by OpenAI GPT-4o-mini that simulates realistic human computer behavior.

## 🤖 What Makes This Special?

Unlike the basic dummy_agent that follows a fixed script, this LLM-powered agent:

- **Makes intelligent decisions** based on NPC personality and role
- **Generates realistic commands** that a real person in that role would execute
- **Adapts behavior** based on previous actions and context
- **Creates diverse activities** mixing work, learning, and exploration
- **Maintains character consistency** throughout the session

## 🎭 Available NPCs

### Dr. Sarah Chen - AI Research Scientist
- **Personality**: Curious, methodical, perfectionist
- **Behavior**: Creates detailed notes, organizes data, experiments with ML tools
- **Workspace Style**: Highly organized with ISO-dated files

### Marcus Rodriguez - DevOps Engineer
- **Personality**: Pragmatic, automation-focused, efficient
- **Behavior**: Writes automation scripts, monitors systems, creates backups
- **Workspace Style**: Script-heavy and practical

### Emma Thompson - Junior Web Developer
- **Personality**: Enthusiastic, learning-oriented, creative
- **Behavior**: Experiments with frameworks, creates test projects, takes notes
- **Workspace Style**: Experimental and sometimes messy

## 📋 Architecture

```
┌─────────────────┐
│  GHOSTS Client  │
│   (Timeline)    │
└────────┬────────┘
         │ Every 15s: Request next command
         ↓
┌─────────────────┐
│  LLM Service    │
│  (Flask API)    │
│   Port 5555     │
└────────┬────────┘
         │ Sends NPC profile + history
         ↓
┌─────────────────┐
│  OpenAI API     │
│  GPT-4o-mini    │
└────────┬────────┘
         │ Returns intelligent command
         ↓
┌─────────────────┐
│    Workspace    │
│  Files created  │
└─────────────────┘
```

## � Command Logging & Tracking

Every command the agent generates is automatically logged with comprehensive metadata:

- **JSONL Format**: `logs/command_history.jsonl` - Machine-readable
- **CSV Format**: `logs/command_history.csv` - Spreadsheet-friendly

**Each log entry includes:**
- Exact timestamp (ISO 8601 format)
- NPC name and role
- Full command executed
- Working directory
- Delay after execution
- LLM model used
- Session ID (daily)

**View logs:**
```bash
./view-logs.sh stats    # Statistics
./view-logs.sh recent   # Recent commands
./view-logs.sh tail     # Live monitoring
```

See [LOGGING.md](LOGGING.md) for complete documentation on log analysis, time calculations, and integration with data tools.

---

## �🚀 Quick Start

### 1. Setup (First Time Only)

```bash
cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent

# Install dependencies
./setup.sh
```

### 2. Configure OpenAI API Key

```bash
# Set your API key
export OPENAI_API_KEY='sk-your-actual-api-key-here'

# Or create a .env file
cp .env.example .env
# Edit .env with your key, then:
source .env
```

### 3. Choose Your NPC

```bash
# See available NPCs
./switch-npc.sh

# Switch to a specific NPC
./switch-npc.sh sarah_chen      # AI Researcher
./switch-npc.sh marcus_rodriguez # DevOps Engineer
./switch-npc.sh emma_thompson    # Web Developer
```

### 4. Start LLM Service

```bash
# In terminal 1
./start-llm-service.sh
```

Wait for:
```
 * Running on http://0.0.0.0:5555
```

### 5. Start GHOSTS Agent

```bash
# In terminal 2
./run-agent.sh
```

## 🎮 Usage

### Monitor Activity

**Watch workspace in real-time:**
```bash
watch -n 2 'ls -lRt workspace/ | tail -20'
```

**View LLM service logs:**
The service shows each command it generates

**Check action history:**
```bash
curl http://localhost:5555/history | python3 -m json.tool
```

### Switch NPCs on the Fly

```bash
# Switch NPC
./switch-npc.sh marcus_rodriguez

# Reload in running service
curl -X POST http://localhost:5555/reload-npc
```

### Test LLM Service

```bash
# Health check
curl http://localhost:5555/health | python3 -m json.tool

# Get a command
curl http://localhost:5555/next-command | python3 -m json.tool

# View command history
curl http://localhost:5555/history
```

## 📁 Directory Structure

```
dummy_llm_agent/
├── 🚀 setup.sh                  # One-time setup
├── 🤖 start-llm-service.sh      # Start LLM decision service
├── 🎬 run-agent.sh              # Start GHOSTS agent
├── 🎭 switch-npc.sh             # Change NPC personality
│
├── llm_service.py               # LLM decision service (Flask)
├── requirements.txt             # Python dependencies
│
├── bin/                         # GHOSTS binaries
│   └── config/
│       ├── application.json     # Agent config
│       └── timeline.json        # Calls LLM service
│
├── config/                      # Config templates
├── workspace/                   # ⭐ AGENT WORKING DIRECTORY
├── logs/                        # Service logs
│
└── npc_profiles/                # NPC personality files
    ├── sarah_chen.json
    ├── marcus_rodriguez.json
    ├── emma_thompson.json
    └── current_npc.json         # Active NPC
```

## ⚙️ How It Works

1. **GHOSTS Timeline** runs every 15 seconds
2. **Timeline** calls LLM service: `curl http://localhost:5555/next-command`
3. **LLM Service** receives request with NPC profile and history
4. **OpenAI GPT-4o-mini** generates a realistic bash command for that NPC
5. **Command** is returned and executed in the workspace
6. **Result** is logged and added to history
7. **Repeat** with growing context

## 🎯 Example Commands Generated

**Dr. Sarah Chen might do:**
```bash
mkdir -p research/neural_networks/experiments
echo "Experiment notes - $(date)" > research/notes.txt
python3 -c "print('Data analysis simulation')" > analysis.log
```

**Marcus Rodriguez might do:**
```bash
cat > deploy_script.sh << 'EOF'
#!/bin/bash
echo "Deployment at $(date)"
EOF
chmod +x deploy_script.sh
./deploy_script.sh > deployment.log
```

**Emma Thompson might do:**
```bash
mkdir -p projects/my-awesome-app/src
echo "<h1>Hello World</h1>" > projects/my-awesome-app/index.html
echo "TODO: Add JavaScript" > projects/my-awesome-app/notes.txt
```

## 🔧 Customization

### Create Your Own NPC

```bash
cd npc_profiles
cp sarah_chen.json custom_npc.json
# Edit custom_npc.json with your personality
./switch-npc.sh custom_npc
```

### Adjust Timing

Edit `config/timeline.json`:
```json
"DelayAfter": 15000,  // 15 seconds between commands
"DelayBefore": 2000   // 2 second delay before command
```

### Change Model/Temperature

Edit `llm_service.py`:
```python
model="gpt-4o-mini",      # or "gpt-4", "gpt-3.5-turbo"
temperature=0.8           # 0.0-2.0 (higher = more creative)
```

## 🐛 Troubleshooting

### "LLM Service not detected"
- Make sure `./start-llm-service.sh` is running
- Check port 5555 is not in use: `lsof -i :5555`

### "Mock mode active"
- OPENAI_API_KEY not set
- Export your API key: `export OPENAI_API_KEY='sk-...'`

### Commands not executing
- Check workspace permissions
- View LLM service logs for errors
- Test manually: `curl http://localhost:5555/next-command`

### Agent crashes
- Check .NET is installed: `dotnet --version`
- View agent logs in `bin/logs/`

## 💰 Cost Considerations

**GPT-4o-mini** is very affordable:
- ~$0.00015 per request (150 tokens average)
- At 4 commands/minute: ~$0.036/hour
- 24 hours: ~$0.86/day

**Optimization tips:**
- Increase `DelayAfter` to reduce API calls
- Use mock mode for testing
- Set budget limits in OpenAI dashboard

## 📊 Monitoring

### Service Health
```bash
curl http://localhost:5555/health
```

### Command History
```bash
curl http://localhost:5555/history | jq .
```

### Workspace Activity
```bash
# Real-time file creation
watch -n 1 'find workspace -type f -printf "%T@ %p\n" | sort -n | tail -10 | cut -d" " -f2-'
```

## 🛑 Stopping

```bash
# Stop agent: Ctrl+C in agent terminal
# Stop LLM service: Ctrl+C in service terminal

# Or kill processes:
pkill -f "Ghosts.Client.Universal"
pkill -f "llm_service.py"
```

## 🔐 Security Notes

- **Never commit** `.env` or files with API keys
- API key has access to your OpenAI account
- Agent runs with your user permissions
- All commands execute in `workspace/` directory
- Review generated commands before production use

## 📚 Resources

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [GHOSTS Framework](https://cmu-sei.github.io/GHOSTS/)
- [Flask Documentation](https://flask.palletsprojects.com/)

---

**Ready to see AI-powered NPCs in action!** 🚀

Start with: `./setup.sh && export OPENAI_API_KEY='your-key' && ./start-llm-service.sh`
