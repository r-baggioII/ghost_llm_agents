#!/usr/bin/env python3
"""
GHOSTS LLM Decision Service
This service uses OpenAI GPT-4o-mini to make intelligent decisions for GHOSTS agents.
It receives NPC profiles and history, then generates appropriate commands.
"""

import os
import json
import time
from datetime import datetime
from flask import Flask, request, jsonify
from openai import OpenAI
import logging
import csv

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Command tracking
COMMAND_LOG_DIR = '/home/rocio/Documentos/GHOSTS/dummy_llm_agent/logs'
COMMAND_LOG_FILE = os.path.join(COMMAND_LOG_DIR, 'command_history.jsonl')
COMMAND_CSV_FILE = os.path.join(COMMAND_LOG_DIR, 'command_history.csv')

# Ensure logs directory exists
os.makedirs(COMMAND_LOG_DIR, exist_ok=True)

# Initialize OpenAI client
client = None
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', '')

if OPENAI_API_KEY:
    client = OpenAI(api_key=OPENAI_API_KEY)
    logger.info("✅ OpenAI client initialized")
else:
    logger.warning("⚠️  OPENAI_API_KEY not set. Service will run in mock mode.")

# Load NPC profile
NPC_PROFILE = {}
NPC_PROFILE_PATH = '/home/rocio/Documentos/GHOSTS/dummy_llm_agent/npc_profiles/current_npc.json'

def load_npc_profile():
    """Load the current NPC profile"""
    global NPC_PROFILE
    try:
        if os.path.exists(NPC_PROFILE_PATH):
            with open(NPC_PROFILE_PATH, 'r') as f:
                NPC_PROFILE = json.load(f)
                logger.info(f"📋 Loaded NPC: {NPC_PROFILE.get('name', 'Unknown')}")
        else:
            logger.warning(f"NPC profile not found at {NPC_PROFILE_PATH}")
    except Exception as e:
        logger.error(f"Error loading NPC profile: {e}")

# Load profile on startup
load_npc_profile()

# Action history for context
action_history = []
MAX_HISTORY = 10

def log_command_to_file(command_data):
    """Log command execution to both JSONL and CSV files"""
    try:
        # Log to JSONL (one JSON object per line)
        with open(COMMAND_LOG_FILE, 'a') as f:
            f.write(json.dumps(command_data) + '\n')
        
        # Log to CSV
        file_exists = os.path.isfile(COMMAND_CSV_FILE)
        with open(COMMAND_CSV_FILE, 'a', newline='') as csvfile:
            fieldnames = ['timestamp', 'npc_name', 'npc_role', 'command', 
                         'working_directory', 'delay_after', 'llm_model', 'session_id']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            
            if not file_exists:
                writer.writeheader()
            
            writer.writerow(command_data)
        
        logger.info(f"📝 Command logged to files")
        
    except Exception as e:
        logger.error(f"Error logging command: {e}")

def get_system_prompt():
    """Generate system prompt based on NPC profile"""
    npc_name = NPC_PROFILE.get('name', 'Agent')
    npc_role = NPC_PROFILE.get('role', 'user')
    npc_personality = NPC_PROFILE.get('personality', 'curious and helpful')
    npc_interests = ', '.join(NPC_PROFILE.get('interests', ['technology', 'learning']))
    
    return f"""You are simulating the computer activity of {npc_name}, a {npc_role}.

Personality: {npc_personality}
Interests: {npc_interests}
Working Directory: /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace/

Your job is to generate realistic Linux bash commands that this person would execute on their computer.
The commands should:
1. Be realistic and appropriate for this person's role and interests
2. Create files, folders, or perform tasks related to their work/interests
3. Be safe and non-destructive
4. Stay within the workspace directory
5. Show human-like behavior (mix of work, learning, curiosity)

IMPORTANT RULES:
- ALWAYS start commands with: cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace &&
- Generate ONE command at a time
- Be creative but realistic
- Mix different types of activities (creating files, organizing, researching, learning)
- Sometimes do mundane tasks, sometimes interesting ones
- Respond ONLY with the bash command, no explanations

Example commands:
cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace && mkdir -p projects/ai_research
cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace && echo "Research notes on neural networks" > notes.txt
cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace && find . -name "*.txt" -exec wc -l {{}} \\;
"""

def generate_command_with_llm(context=""):
    """Use OpenAI to generate the next command"""
    if not client:
        # Mock mode - return predefined commands
        mock_commands = [
            "cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace && mkdir -p documents && echo 'Mock mode active' > documents/readme.txt",
            "cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace && ls -lah",
            "cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace && date > timestamp.txt"
        ]
        import random
        return random.choice(mock_commands)
    
    try:
        # Build conversation context
        messages = [
            {"role": "system", "content": get_system_prompt()}
        ]
        
        # Add recent history
        if action_history:
            history_text = "Recent activities:\n" + "\n".join(action_history[-5:])
            messages.append({"role": "user", "content": f"{history_text}\n\nWhat should I do next?"})
        else:
            messages.append({"role": "user", "content": "What should I do first on my computer?"})
        
        # Call OpenAI
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=messages,
            max_tokens=150,
            temperature=0.8
        )
        
        command = response.choices[0].message.content.strip()
        
        # Ensure command starts with cd to workspace
        if not command.startswith("cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace"):
            command = f"cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace && {command}"
        
        logger.info(f"🤖 Generated command: {command[:100]}...")
        return command
        
    except Exception as e:
        logger.error(f"Error calling OpenAI: {e}")
        return "cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace && echo 'LLM error' > error.log"

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "llm_enabled": client is not None,
        "npc_loaded": bool(NPC_PROFILE),
        "npc_name": NPC_PROFILE.get('name', 'Not loaded'),
        "timestamp": datetime.now().isoformat()
    })

@app.route('/next-command', methods=['POST', 'GET'])
def next_command():
    """Generate the next command for the agent"""
    try:
        # Get context from request if available
        context = ""
        if request.method == 'POST' and request.json:
            context = request.json.get('context', '')
            last_command = request.json.get('last_command', '')
            if last_command:
                action_history.append(f"[{datetime.now().strftime('%H:%M')}] {last_command}")
                # Keep only recent history
                if len(action_history) > MAX_HISTORY:
                    action_history.pop(0)
        
        # Generate command
        command_timestamp = datetime.now()
        command = generate_command_with_llm(context)
        
        # Log command details
        command_data = {
            'timestamp': command_timestamp.isoformat(),
            'npc_name': NPC_PROFILE.get('name', 'Unknown'),
            'npc_role': NPC_PROFILE.get('role', 'Unknown'),
            'command': command,
            'working_directory': '/home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace',
            'delay_after': 15,  # seconds (from timeline config)
            'llm_model': 'gpt-4o-mini' if client else 'mock',
            'session_id': command_timestamp.strftime('%Y%m%d')
        }
        
        # Save to log files
        log_command_to_file(command_data)
        
        return jsonify({
            "success": True,
            "command": command,
            "npc": NPC_PROFILE.get('name', 'Agent'),
            "timestamp": command_timestamp.isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error in next_command: {e}")
        return jsonify({
            "success": False,
            "error": str(e),
            "command": "cd /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace && echo 'Service error'"
        }), 500

@app.route('/reload-npc', methods=['POST'])
def reload_npc():
    """Reload NPC profile"""
    load_npc_profile()
    return jsonify({
        "success": True,
        "npc_name": NPC_PROFILE.get('name', 'Unknown'),
        "message": "NPC profile reloaded"
    })

@app.route('/history', methods=['GET'])
def get_history():
    """Get action history"""
    return jsonify({
        "history": action_history,
        "count": len(action_history)
    })

if __name__ == '__main__':
    print("=" * 50)
    print("  GHOSTS LLM Decision Service")
    print("=" * 50)
    print(f"OpenAI Enabled: {client is not None}")
    print(f"NPC Profile: {NPC_PROFILE.get('name', 'Not loaded')}")
    print(f"Workspace: /home/rocio/Documentos/GHOSTS/dummy_llm_agent/workspace/")
    print("=" * 50)
    print("\nStarting service on http://localhost:5555")
    print("Endpoints:")
    print("  GET  /health - Health check")
    print("  GET  /next-command - Get next command")
    print("  POST /next-command - Get next command with context")
    print("  GET  /history - View action history")
    print("=" * 50)
    
    app.run(host='0.0.0.0', port=5555, debug=True)
