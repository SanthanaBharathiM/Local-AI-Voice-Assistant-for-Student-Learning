# Installation Guide

> Step-by-step setup for Windows, macOS, and Linux

---

## Prerequisites

**Minimum Requirements:**
- Python 3.10 or higher
- 2GB RAM (4GB recommended)
- 3GB disk space for models
- Working microphone and speakers

**Supported Operating Systems:**
- ✅ Windows 10/11 (with WSL2 recommended for best experience)
- ✅ macOS 11+ (Intel & Apple Silicon)
- ✅ Linux (Ubuntu 20.04+, Debian, Fedora)

---

## Automatic Installation (Recommended)

### Windows PowerShell

```powershell
# 1. Clone repository
git clone https://github.com/SanthanaBharathiM/Local-AI-Voice-Assistant-for-Student-Learning.git
cd Local-AI-Voice-Assistant-for-Student-Learning

# 2. Run setup script (requires PowerShell 5.0+)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\setup.ps1

# 3. Run the assistant
python src/voice_assistant.py
```

### macOS / Linux (Bash/Zsh)

```bash
# 1. Clone repository
git clone https://github.com/SanthanaBharathiM/Local-AI-Voice-Assistant-for-Student-Learning.git
cd Local-AI-Voice-Assistant-for-Student-Learning

# 2. Make setup executable and run
chmod +x setup.sh
./setup.sh

# 3. Run the assistant
python src/voice_assistant.py
```

---

## Manual Installation (Step-by-Step)

### Step 1: Clone Repository

```bash
git clone https://github.com/SanthanaBharathiM/Local-AI-Voice-Assistant-for-Student-Learning.git
cd Local-AI-Voice-Assistant-for-Student-Learning
```

### Step 2: Create Virtual Environment

**Windows (PowerShell):**
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

**macOS / Linux (Bash):**
```bash
python3 -m venv venv
source venv/bin/activate
```

### Step 3: Install Python Dependencies

```bash
# Upgrade pip
pip install --upgrade pip

# Install required packages
pip install -r requirements.txt
```

**Expected output:**
```
Successfully installed pipecat-ai==0.1.8
Successfully installed ollama==0.2.0
Successfully installed kokoro-onnx==0.3.0
...
```

### Step 4: Install Ollama

Ollama runs local LLM inference. Download and install for your OS:

**Windows:**
1. Download from: https://ollama.ai/download/windows
2. Run installer (ollama-windows-amd64.exe)
3. Follow installation wizard
4. Restart terminal

**macOS:**
```bash
# Via Homebrew (recommended)
brew install ollama

# OR download from: https://ollama.ai/download/mac
```

**Linux (Ubuntu/Debian):**
```bash
# Install via script
curl -fsSL https://ollama.ai/install.sh | sh

# Start Ollama service
sudo systemctl start ollama
```

**Linux (Fedora/CentOS):**
```bash
sudo dnf install ollama
sudo systemctl start ollama
```

### Step 5: Pull Llama 3.2 Model

**Start Ollama service in a separate terminal:**

**Windows (PowerShell):**
```powershell
ollama serve
```

**macOS / Linux:**
```bash
ollama serve
```

**In another terminal, pull the model:**
```bash
ollama pull llama3.2
```

**Expected output:**
```
pulling manifest ⠋
pulling 8934d3bdbed5 100% |████████████████████| (1.1 GB / 1.1 GB)
pulling 3f9d92cfbf40 100% |████████████████████| (7.4 MB / 7.4 MB)
...
✅ success
```

**Verify installation:**
```bash
ollama list

# Should show:
# NAME          ID              SIZE    MODIFIED
# llama3.2      3f9d92cfbf40    1.1 GB  2 minutes ago
```

### Step 6: Download Kokoro TTS Models

The setup scripts handle this automatically, but you can also download manually:

**Windows (PowerShell):**
```powershell
python -c "from kokoro_onnx import Kokoro; Kokoro('models/kokoro-v1.0.onnx', 'models/voices-v1.0.bin')"
```

**macOS / Linux (Bash):**
```bash
python3 -c "from kokoro_onnx import Kokoro; Kokoro('models/kokoro-v1.0.onnx', 'models/voices-v1.0.bin')"
```

**Or run Python script:**
```python
from kokoro_onnx import Kokoro
import os

# Create models directory
os.makedirs("models", exist_ok=True)

# Download models
tts = Kokoro("models/kokoro-v1.0.onnx", "models/voices-v1.0.bin")
print("✅ Models downloaded successfully!")
```

### Step 7: Verify Installation

```bash
# Check Python version
python --version
# Should be 3.10+

# Check virtual environment
which python  # (macOS/Linux)
# or
Get-Command python  # (Windows PowerShell)

# Check Ollama is running
ollama list
# Should show llama3.2

# Check models directory
ls -la models/  # (macOS/Linux)
# or
dir models  # (Windows)
# Should show: kokoro-v1.0.onnx, voices-v1.0.bin
```

### Step 8: Run the Assistant

**In terminal with virtual environment activated:**

```bash
# Make sure Ollama is running in another terminal
python src/voice_assistant.py
```

**Expected output:**
```
🎙️ Loading Kokoro ONNX TTS...
✅ Ready!

🎙️ TEACHING ASSISTANT ONLINE
✅ System Ready. Listening for your voice...
```

Speak naturally. The assistant will respond in 6-8 seconds.

---

## Troubleshooting Installation

### Problem: Python 3.10+ Not Found

**Windows:**
```powershell
# Check installed Python versions
py --list-paths

# If not installed, download from: https://www.python.org/downloads/
# Make sure to check "Add Python to PATH" during installation
```

**macOS:**
```bash
# Check version
python3 --version

# If outdated, install via Homebrew:
brew install python@3.11
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install python3.10 python3.10-venv

# Fedora
sudo dnf install python3.10
```

### Problem: Ollama Command Not Found

**Windows:**
- Close and reopen PowerShell/CMD after installation
- Check PATH environment variable
- Reinstall Ollama if necessary

**macOS:**
```bash
# If installed via Homebrew
brew info ollama

# Add to PATH if needed
export PATH="/opt/homebrew/bin:$PATH"
```

**Linux:**
```bash
# Check if installed
which ollama
# If not found:
curl -fsSL https://ollama.ai/install.sh | sh
```

### Problem: Kokoro Models Not Downloading

```bash
# Manual download with error handling
python -c "
import os
os.makedirs('models', exist_ok=True)
try:
    from kokoro_onnx import Kokoro
    tts = Kokoro('models/kokoro-v1.0.onnx', 'models/voices-v1.0.bin')
    print('✅ Models downloaded')
except Exception as e:
    print(f'❌ Error: {e}')
    print('Try again or check internet connection')
"
```

### Problem: Virtual Environment Issues

**Deactivate and recreate:**

```bash
# Deactivate current venv
deactivate

# Remove old venv
rm -rf venv  # (macOS/Linux)
rmdir /s venv  # (Windows)

# Create fresh venv
python -m venv venv

# Activate
source venv/bin/activate  # (macOS/Linux)
# or
.\venv\Scripts\Activate.ps1  # (Windows)

# Reinstall dependencies
pip install -r requirements.txt
```

### Problem: Audio Not Working

**Check audio devices:**

**Windows (PowerShell):**
```powershell
# List audio devices
Get-PnpDevice -Class AudioEndpoint | Select-Object Name, Status

# Check microphone permissions in Settings → Privacy & Security → Microphone
```

**macOS:**
```bash
# List audio devices
system_profiler SPAudioDataType

# Grant microphone permission:
# System Settings → Privacy & Security → Microphone
```

**Linux:**
```bash
# Check ALSA devices
arecord -l
aplay -l

# Or use PulseAudio
pactl list sources
pactl list sinks
```

### Problem: Ollama Not Responding

**Check Ollama is running:**

```bash
# Test connection
curl http://localhost:11434/api/tags

# Should return JSON with available models
```

**Restart Ollama:**

```bash
# Windows (in PowerShell)
Ctrl+C  # Stop current session
ollama serve  # Restart

# macOS/Linux
sudo systemctl restart ollama
# or
pkill ollama
ollama serve
```

---

## Environment Variables (Optional)

Create `.env` file for custom configuration:

```bash
# .env file
OLLAMA_HOST=http://localhost:11434/v1
LLM_MODEL=llama3.2
TTS_VOICE=af_heart
STT_MODEL_SIZE=tiny
LOG_LEVEL=INFO
```

**Load in Python:**
```python
from dotenv import load_dotenv
import os

load_dotenv()
ollama_host = os.getenv("OLLAMA_HOST", "http://localhost:11434/v1")
```

---

## Docker Installation (Optional)

Skip all above steps with containerization:

```bash
# Build container
docker build -t voice-assistant .

# Run container
docker run -it --rm \
  -v /dev/snd:/dev/snd \
  -v $(pwd)/models:/app/models \
  voice-assistant
```

See `examples/docker/Dockerfile` for details.

---

## Next Steps After Installation

1. ✅ Run voice assistant: `python src/voice_assistant.py`
2. ✅ Read [ARCHITECTURE.md](ARCHITECTURE.md) to understand the system
3. ✅ Check [CUSTOMIZATION.md](CUSTOMIZATION.md) to modify prompts
4. ✅ View [PERFORMANCE.md](PERFORMANCE.md) for benchmarks
5. ✅ Join discussions: GitHub Issues & Discussions

---

## Getting Help

**Installation Issues?**
1. Check [FAQ.md](FAQ.md) for common problems
2. Open GitHub Issue with:
   - Your OS and Python version
   - Full error message
   - Steps to reproduce
3. Check existing issues first

---

**Installation Complete! 🎉**

Your system is ready for voice-based learning assistance.