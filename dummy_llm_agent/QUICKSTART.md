# GHOSTS LLM Agent - Quick Start

## 🚀 Get Started in 3 Steps

### 1️⃣ Setup
```bash
cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent
./setup.sh
```

### 2️⃣ Set API Key
```bash
export OPENAI_API_KEY='sk-your-actual-key-here'
```

### 3️⃣ Run (Two Terminals)

**Terminal 1 - LLM Service:**
```bash
./start-llm-service.sh
```

**Terminal 2 - GHOSTS Agent:**
```bash
./run-agent.sh
```

## 🎭 NPCs Available

- **sarah_chen** - AI Research Scientist (organized, methodical)
- **marcus_rodriguez** - DevOps Engineer (automation-focused)
- **emma_thompson** - Junior Web Developer (enthusiastic, experimental)

Switch with: `./switch-npc.sh <name>`

## 👀 Monitor

```bash
# Check status
./info.sh

# Watch workspace
watch -n 2 'ls -lRt workspace/ | tail -20'

# View history
curl http://localhost:5555/history
```

## 🎯 What It Does

The LLM agent:
1. Gets NPC personality and history
2. Asks OpenAI GPT-4o-mini: "What should this person do next?"
3. Executes the generated command in workspace/
4. Repeats every 15 seconds with growing context

**Commands are smart and contextual!**

## 💡 Features

✅ Intelligent decision-making based on personality
✅ Realistic human-like behavior
✅ Adaptive to previous actions
✅ 3 pre-built NPC personalities
✅ Easy to create custom NPCs
✅ Runs in isolated workspace
✅ Full API for monitoring

## 📝 Example Output

**Dr. Sarah Chen** might create:
- research/ folders with experiments
- Python analysis scripts
- Detailed note files with ISO dates
- Data organization structures

**Marcus Rodriguez** might create:
- Automation bash scripts
- Deployment configurations
- System monitoring files
- Backup scripts

**Emma Thompson** might create:
- HTML/CSS/JS project files
- Tutorial code snippets  
- Multiple "test" folders
- Learning notes

## 🔧 Requirements

- Python 3.7+
- .NET 8.0
- OpenAI API key (get from platform.openai.com)
- Internet connection

## 📊 Cost

GPT-4o-mini: ~$0.036/hour = ~$0.86/day

Very affordable for testing and demos!

## 🐛 Troubleshooting

**"Service not detected"**
- Start LLM service first: `./start-llm-service.sh`

**"Mock mode"**  
- Set API key: `export OPENAI_API_KEY='sk-...'`

**No commands executing**
- Check both services are running: `./info.sh`

## 📚 Full Docs

See `README.md` for complete documentation.

---

**Start now:** `./setup.sh` ✨
