# Local AI Voice Assistant - Setup Script for Windows
# Requires PowerShell 5.0+ (comes with Windows 10+)
# 
# Usage:
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#   .\setup.ps1

# Stop on error
$ErrorActionPreference = "Stop"

# Color functions
function Write-Header {
    param([string]$Message)
    Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Yellow
}

# Detect OS (should be Windows)
Write-Header "Local AI Voice Assistant Setup (Windows)"
Write-Info "Detected OS: Windows"
Write-Host ""

# Step 1: Check Python version
Write-Info "Checking Python installation..."
try {
    $pythonVersion = python --version 2>&1
    Write-Success "Python found: $pythonVersion"
} catch {
    Write-Error-Custom "Python not found"
    Write-Host "Download Python 3.10+ from: https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host "Make sure to check 'Add Python to PATH' during installation" -ForegroundColor Yellow
    exit 1
}

# Verify version is 3.10+
$version = python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
if ($version -lt "3.10") {
    Write-Error-Custom "Python 3.10+ required. Found: $version"
    exit 1
}
Write-Success "Python version $version meets requirements"
Write-Host ""

# Step 2: Create virtual environment
Write-Info "Creating virtual environment..."
if (Test-Path "venv") {
    Write-Info "Virtual environment already exists"
} else {
    python -m venv venv
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Virtual environment created"
    } else {
        Write-Error-Custom "Failed to create virtual environment"
        exit 1
    }
}
Write-Host ""

# Step 3: Activate virtual environment
Write-Info "Activating virtual environment..."
& ".\venv\Scripts\Activate.ps1"
if ($LASTEXITCODE -eq 0) {
    Write-Success "Virtual environment activated"
} else {
    Write-Error-Custom "Failed to activate virtual environment"
    Write-Host "Try manually: .\venv\Scripts\Activate.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Step 4: Upgrade pip
Write-Info "Upgrading pip..."
python -m pip install --upgrade pip --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Success "pip upgraded"
} else {
    Write-Error-Custom "Failed to upgrade pip"
    exit 1
}
Write-Host ""

# Step 5: Install Python dependencies
Write-Info "Installing Python dependencies..."
Write-Info "This may take 2-3 minutes..."
pip install -r requirements.txt
if ($LASTEXITCODE -eq 0) {
    Write-Success "Python dependencies installed"
} else {
    Write-Error-Custom "Failed to install dependencies"
    exit 1
}
Write-Host ""

# Step 6: Check for Ollama
Write-Info "Checking for Ollama installation..."
$ollamaCheck = Get-Command ollama -ErrorAction SilentlyContinue
if ($ollamaCheck) {
    Write-Success "Ollama is installed"
    $ollamaVersion = ollama --version
    Write-Host "Version: $ollamaVersion"
} else {
    Write-Error-Custom "Ollama not found"
    Write-Host ""
    Write-Info "Install Ollama:"
    Write-Host "1. Download from: https://ollama.ai/download/windows" -ForegroundColor Yellow
    Write-Host "2. Run the installer (ollama-windows-amd64.exe)" -ForegroundColor Yellow
    Write-Host "3. Restart PowerShell" -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Continue anyway? (y/n)"
    if ($response -ne "y") {
        exit 1
    }
}
Write-Host ""

# Step 7: Create models directory
Write-Info "Creating models directory..."
if (-not (Test-Path "models")) {
    New-Item -ItemType Directory -Path "models" -Force | Out-Null
}
Write-Success "Models directory ready"
Write-Host ""

# Step 8: Download Kokoro TTS models
Write-Info "Checking Kokoro TTS models..."
$kokoroModel = Test-Path "models/kokoro-v1.0.onnx"
$voicesModel = Test-Path "models/voices-v1.0.bin"

if (-not $kokoroModel -or -not $voicesModel) {
    Write-Info "Downloading Kokoro models..."
    Write-Info "This will take 5-10 minutes and download ~500MB..."
    Write-Info "Make sure you have a good internet connection"
    Write-Host ""
    
    $pyScript = @"
import os
import sys

os.makedirs("models", exist_ok=True)

try:
    print("⏳ Downloading Kokoro TTS models...")
    from kokoro_onnx import Kokoro
    tts = Kokoro("models/kokoro-v1.0.onnx", "models/voices-v1.0.bin")
    print("\n✅ Kokoro models downloaded successfully!")
except Exception as e:
    print(f"\n❌ Error downloading Kokoro models: {e}")
    print("\nTroubleshooting:")
    print("1. Check internet connection")
    print("2. Check if HuggingFace is accessible")
    print("3. Try manually later: python -c \"from kokoro_onnx import Kokoro; Kokoro('models/kokoro-v1.0.onnx', 'models/voices-v1.0.bin')\"")
    sys.exit(1)
"@
    
    python -c $pyScript
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to download Kokoro models"
        Write-Host "You can retry later by running:" -ForegroundColor Yellow
        Write-Host "  .\venv\Scripts\Activate.ps1" -ForegroundColor Cyan
        Write-Host "  python -c \"from kokoro_onnx import Kokoro; Kokoro('models/kokoro-v1.0.onnx', 'models/voices-v1.0.bin')\"" -ForegroundColor Cyan
        exit 1
    }
} else {
    Write-Success "Kokoro models already downloaded"
}
Write-Host ""

# Step 9: Check Llama 3.2
Write-Info "Checking Llama 3.2 model..."
$ollamaCheck = Get-Command ollama -ErrorAction SilentlyContinue
if ($ollamaCheck) {
    try {
        $modelList = ollama list 2>$null
        if ($modelList -match "llama3.2") {
            Write-Success "Llama 3.2 model already installed"
        } else {
            Write-Info "Llama 3.2 not found. Download instructions:"
            Write-Host "1. Start Ollama service: ollama serve" -ForegroundColor Yellow
            Write-Host "2. In another PowerShell, run: ollama pull llama3.2" -ForegroundColor Yellow
            Write-Host "3. This will download ~1.1GB (takes 10-15 minutes)" -ForegroundColor Yellow
        }
    } catch {
        Write-Info "Could not check Ollama status"
    }
} else {
    Write-Info "Ollama not installed, skipping model check"
}
Write-Host ""

# Step 10: Verify installation
Write-Info "Verifying installation..."

$pyScript = @"
import sys

checks = {
    "pipecat": "Pipecat framework",
    "ollama": "Ollama client",
    "kokoro_onnx": "Kokoro TTS",
    "openai": "OpenAI library",
    "whisper": "Whisper STT",
}

all_ok = True
for module, name in checks.items():
    try:
        __import__(module)
        print(f"✅ {name}")
    except ImportError:
        print(f"❌ {name} - not installed")
        all_ok = False

if not all_ok:
    sys.exit(1)
"@

python -c $pyScript

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Some packages failed verification"
    exit 1
}
Write-Success "All packages verified"
Write-Host ""

# Step 11: Success message and next steps
Write-Header "Setup Complete! 🎉"
Write-Success "Installation finished successfully!"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Start Ollama (in another PowerShell window):" -ForegroundColor Yellow
Write-Host "   ollama serve" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Activate virtual environment:" -ForegroundColor Yellow
Write-Host "   .\venv\Scripts\Activate.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Run the voice assistant:" -ForegroundColor Yellow
Write-Host "   python src/voice_assistant.py" -ForegroundColor Cyan
Write-Host ""
Write-Host "Useful links:" -ForegroundColor Cyan
Write-Host "- Documentation: README.md" -ForegroundColor Gray
Write-Host "- Installation help: INSTALLATION.md" -ForegroundColor Gray
Write-Host "- Architecture: ARCHITECTURE.md" -ForegroundColor Gray
Write-Host "- FAQ: FAQ.md" -ForegroundColor Gray
Write-Host ""
Write-Host "Happy learning! 🚀" -ForegroundColor Green
Write-Host ""
