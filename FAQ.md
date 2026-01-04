# FAQ - Frequently Asked Questions

> Solutions to common problems and questions

---

## Installation & Setup

### Q: "ModuleNotFoundError: No module named 'pipecat'"
**A:** Virtual environment not activated or dependencies not installed.

```bash
# Activate virtual environment
source venv/bin/activate  # macOS/Linux
# or
.\venv\Scripts\Activate.ps1  # Windows

# Reinstall dependencies
pip install -r requirements.txt
```

---

### Q: "Python 3.10+ not found"
**A:** You have Python 3.9 or older installed.

```bash
# Check version
python --version

# Install Python 3.10+ from:
# https://www.python.org/downloads/

# macOS via Homebrew:
brew install python@3.11
```

---

### Q: "Ollama command not found"
**A:** Ollama not installed or not in PATH.

```bash
# Windows: Close and reopen PowerShell after installation
# macOS: brew install ollama
# Linux: curl -fsSL https://ollama.ai/install.sh | sh

# Verify:
ollama --version
```

---

### Q: "Kokoro models failed to download"
**A:** Network issue or HuggingFace unreachable.

```bash
# Check internet connection
ping huggingface.co

# Try manual download
python -c "from kokoro_onnx import Kokoro; Kokoro('models/kokoro-v1.0.onnx', 'models/voices-v1.0.bin')"

# If still fails, check:
# 1. VPN/proxy blocking HuggingFace
# 2. Disk space available
# 3. Try later (server might be slow)
```

---

### Q: "'models' directory doesn't exist"
**A:** Setup didn't create the directory.

```bash
# Create manually
mkdir models

# Then download:
python -c "from kokoro_onnx import Kokoro; Kokoro('models/kokoro-v1.0.onnx', 'models/voices-v1.0.bin')"
```

---

## Runtime Issues

### Q: "No audio input detected"
**A:** Microphone not working or permissions denied.

**Windows:**
```powershell
# Check microphone in Settings
Settings → Privacy & Security → Microphone

# Test audio devices
[System.Diagnostics.Process]::Start("mmsys.cpl")  # Sound settings
```

**macOS:**
```bash
# Check microphone
system_profiler SPAudioDataType

# Grant permissions
System Settings → Privacy & Security → Microphone
```

**Linux:**
```bash
# Test microphone
arecord -l
arecord -d 5 test.wav
aplay test.wav

# Or check PulseAudio
pactl list sources
```

---

### Q: "Assistant not responding (stuck)"
**A:** Ollama service not running.

```bash
# Start Ollama in new terminal
ollama serve

# Or check if already running
curl http://localhost:11434/api/tags

# If nothing returns, Ollama is down
```

---

### Q: "Audio sounds distorted/robotic"
**A:** Sample rate mismatch or audio normalization issue.

```python
# Check in src/kokoro_tts.py
# Ensure audio is normalized:
audio_int16 = (samples * 32767).astype(np.int16)
```

**If still distorted:**
```bash
# Test with different voice
# Edit config.py and set:
TTS_VOICE = "am_adam"  # Try different voice
```

---

### Q: "Very slow responses (20+ seconds)"
**A:** Hardware limitation or background processes.

```bash
# Check CPU usage
# Windows: Task Manager → Performance
# macOS: Activity Monitor
# Linux: top

# Close heavy apps (Chrome, Discord, etc.)

# Check available RAM
# Windows: tasklist | grep ollama
# macOS: ps aux | grep ollama
# Linux: free -h
```

**For permanent improvement:**
- Upgrade RAM to 8GB+
- Use SSD (faster model loading)
- Reduce background apps
- Use server deployment model

---

## Performance Issues

### Q: "Why is it so slow on my laptop?"
**A:** Check your hardware specs.

```python
import psutil

# Available RAM
ram_gb = psutil.virtual_memory().total / (1024**3)
print(f"Available RAM: {ram_gb:.1f}GB")

# CPU count
cpu_count = psutil.cpu_count()
print(f"CPU cores: {cpu_count}")

# If < 4GB RAM or < 4 cores, expect slow responses
```

**Solutions:**
1. Upgrade RAM to 8GB minimum
2. Use smaller STT model: `model_size="tiny"`
3. Close background applications
4. Use server deployment for multiple users

---

### Q: "Using too much disk space (model files)"
**A:** Model cache is large. This is normal.

```bash
# Check size
du -sh models/

# Expected:
# kokoro-v1.0.onnx: ~256MB
# voices-v1.0.bin: ~256MB
# Total: ~500MB
```

**Not a problem unless disk < 1GB**

---

## Customization

### Q: "How do I change the AI's personality?"
**A:** Modify the system prompt.

```python
# Edit src/system_prompts.py

MATH_TUTOR = """
You are a patient math tutor. Break down problems step-by-step.
Use concrete examples before abstract formulas.
Encourage students who are struggling.
"""

# Then in voice_assistant.py:
context = OpenAILLMContext([{"role": "system", "content": MATH_TUTOR}])
```

---

### Q: "How do I use a different LLM?"
**A:** Change the model in config.

```python
# In src/config.py
LLM_MODEL = "mistral"  # Instead of "llama3.2"

# Then pull model
ollama pull mistral
```

**Available models:**
- `llama3.2` (recommended, balanced)
- `mistral` (better reasoning)
- `phi` (smaller, faster)
- `neural-chat` (conversation optimized)

---

### Q: "How do I change the TTS voice?"
**A:** Kokoro supports multiple voices.

```python
# In src/kokoro_tts.py
voice="af_heart"  # Default: supportive female

# Options:
# "af_heart"   - Supportive female (recommended)
# "am_adam"    - Calm male
# "bf_emma"    - Warm female
# "bm_george"  - Friendly male
```

---

## Multi-Language & Localization

### Q: "Can I use this in Hindi/Tamil?"
**A:** Partial support. Roadmap feature.

**Current:**
- ✅ Whisper can detect Hindi/Tamil speech
- ❌ Llama responses in English
- ❌ Kokoro TTS in English

**Roadmap (v1.1.0):**
- Add Hindi/Tamil Llama models
- Add regional language TTS voices
- Full multilingual pipeline

**Workaround:**
```python
# Translate input to English, respond, translate back
from translator import translate

# This adds 2-3s latency
hindi_text = translate(english_response, "hi")
```

---

## Deployment & Scaling

### Q: "How do I deploy for 30 students?"
**A:** Use shared server model, not individual laptops.

```yaml
# docker-compose.yml with 3 servers
version: '3.9'
services:
  ollama:
    image: ollama:latest
    ports:
      - "11434:11434"
  
  assistant:
    build: .
    depends_on:
      - ollama
    replicas: 3  # Load balance across 3 processes
```

**Benefits:**
- 7x cheaper (₹1,50,000 vs ₹10,50,000)
- Central management
- Easy updates
- More reliable

---

### Q: "What if students don't have internet?"
**A:** This project is designed for offline use!

✅ Works completely offline after setup
✅ Perfect for schools without WiFi
✅ Download models once, use forever
✅ No cloud dependency

---

## Privacy & Data

### Q: "Does it collect student data?"
**A:** NO. Everything runs locally.

```
Data Flow:
Student speaks → Processed locally → Response
❌ NO upload to cloud
❌ NO logging to servers
❌ NO third-party access
```

Optional SQLite logging (v1.1.0):
```python
# If enabled, logs stay on device
# Teachers can see: "Question asked, response given"
# But NOT the content (privacy first)
```

---

### Q: "Is it secure?"
**A:** Yes, by design.

✅ No internet required = no network attacks
✅ Open source = auditable code
✅ MIT license = transparent
✅ Local inference = no API keys needed

---

## Debugging

### Q: "How do I see detailed logs?"
**A:** Enable debug logging.

```python
# In src/config.py
LOG_LEVEL = "DEBUG"

# Then run:
python src/voice_assistant.py 2>&1 | tee debug.log
```

**This will show:**
- Model loading details
- Audio processing stats
- LLM inference logs
- Error traces

---

### Q: "How do I profile performance?"
**A:** Use built-in profiling.

```bash
# Profile latency
python -m cProfile -s cumulative src/voice_assistant.py

# Check memory usage
python -m memory_profiler src/voice_assistant.py
```

---

## Contributing & Development

### Q: "How do I contribute improvements?"
**A:** See CONTRIBUTING.md

```bash
# Fork repo → Create feature branch → PR
git checkout -b feature/my-improvement
# Make changes
git push origin feature/my-improvement
# Submit PR with description
```

---

### Q: "Can I add support for [feature]?"
**A:** Check GitHub Issues first, then create Issue/Discussion.

Common requests:
- 🔄 Multi-language (planned v1.1.0)
- 🌐 Web UI (planned v1.2.0)
- 📊 Analytics dashboard (planned v1.2.0)
- 📱 Mobile version (research phase)

---

## Troubleshooting Checklist

**System doesn't start?**
- [ ] Python 3.10+ installed
- [ ] Virtual environment activated
- [ ] Dependencies installed (`pip list | grep pipecat`)
- [ ] Ollama installed and running
- [ ] Kokoro models downloaded

**No audio?**
- [ ] Microphone connected and enabled
- [ ] OS microphone permissions granted
- [ ] Audio devices working
- [ ] Audio sample rates correct (16kHz input, 24kHz output)

**Slow responses?**
- [ ] RAM >= 4GB available
- [ ] CPU not maxed out
- [ ] Ollama service running
- [ ] SSD (not HDD) preferred
- [ ] Background apps closed

**Ollama issues?**
- [ ] Service running: `ollama serve`
- [ ] Port 11434 not blocked
- [ ] Llama 3.2 pulled: `ollama list`
- [ ] Internet for first-time model download

---

## Getting Help

**Resources:**
1. Check this FAQ
2. Read INSTALLATION.md
3. See ARCHITECTURE.md for design details
4. Open GitHub Issue with:
   - Your OS & Python version
   - Exact error message
   - Steps to reproduce
5. Join discussions on GitHub

---

## Known Limitations

| Limitation | Status | Timeline |
|-----------|--------|----------|
| English only | ⏳ Planned | v1.1.0 (Q2 2026) |
| Single voice | ⏳ Planned | v1.1.0 (Q2 2026) |
| No persistence | ⏳ Planned | v1.1.0 (Q2 2026) |
| No GUI | ⏳ Planned | v1.2.0 (Q3 2026) |
| No mobile | 🔬 Research | TBD |

---

**Still stuck? Open an Issue on GitHub!** 🆘