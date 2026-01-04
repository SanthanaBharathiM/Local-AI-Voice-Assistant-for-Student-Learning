#!/bin/bash

# Local AI Voice Assistant - Setup Script for macOS & Linux
# This script automates the entire installation process

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Functions
print_header() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Check if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macOS"
    PYTHON_CMD="python3"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="Linux"
    PYTHON_CMD="python3"
else
    print_error "Unsupported OS: $OSTYPE"
    print_info "This script supports macOS and Linux only."
    print_info "For Windows, use setup.ps1"
    exit 1
fi

print_header "Local AI Voice Assistant Setup ($OS_TYPE)"
echo ""

# Step 1: Check Python version
print_info "Checking Python version..."
PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | awk '{print $2}')
if [[ ! "$PYTHON_VERSION" =~ ^3\.(10|11|12) ]]; then
    print_error "Python 3.10+ required. Found: $PYTHON_VERSION"
    echo "Install Python 3.10+ from https://www.python.org/downloads/"
    exit 1
fi
print_success "Python $PYTHON_VERSION found"
echo ""

# Step 2: Create virtual environment
print_info "Creating virtual environment..."
if [ ! -d "venv" ]; then
    $PYTHON_CMD -m venv venv
    print_success "Virtual environment created"
else
    print_info "Virtual environment already exists"
fi
echo ""

# Step 3: Activate virtual environment
print_info "Activating virtual environment..."
source venv/bin/activate
print_success "Virtual environment activated"
echo ""

# Step 4: Upgrade pip
print_info "Upgrading pip..."
pip install --upgrade pip --quiet
print_success "pip upgraded"
echo ""

# Step 5: Install Python dependencies
print_info "Installing Python dependencies..."
print_info "This may take 2-3 minutes..."
if pip install -r requirements.txt; then
    print_success "Python dependencies installed"
else
    print_error "Failed to install dependencies"
    exit 1
fi
echo ""

# Step 6: Check for Ollama
print_info "Checking for Ollama installation..."
if command -v ollama &> /dev/null; then
    print_success "Ollama is installed"
    OLLAMA_VERSION=$(ollama --version)
    echo "Version: $OLLAMA_VERSION"
else
    print_error "Ollama not found"
    echo ""
    if [[ "$OS_TYPE" == "macOS" ]]; then
        print_info "Install Ollama on macOS:"
        echo "  1. Using Homebrew: brew install ollama"
        echo "  2. Or download from: https://ollama.ai/download/mac"
    else
        print_info "Install Ollama on Linux:"
        echo "  curl -fsSL https://ollama.ai/install.sh | sh"
    fi
    echo ""
    read -p "Continue without Ollama? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo ""

# Step 7: Create models directory
print_info "Creating models directory..."
mkdir -p models
print_success "Models directory ready"
echo ""

# Step 8: Download Kokoro TTS models
print_info "Checking Kokoro TTS models..."
if [ ! -f "models/kokoro-v1.0.onnx" ] || [ ! -f "models/voices-v1.0.bin" ]; then
    print_info "Downloading Kokoro models..."
    print_info "This will take 5-10 minutes and download ~500MB..."
    
    $PYTHON_CMD << EOF
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
    print("3. Try manually: python -c \"from kokoro_onnx import Kokoro; Kokoro('models/kokoro-v1.0.onnx', 'models/voices-v1.0.bin')\"")
    sys.exit(1)
EOF
    
    if [ $? -ne 0 ]; then
        print_error "Failed to download Kokoro models"
        echo "You can retry later by running:"
        echo "  source venv/bin/activate"
        echo "  python -c \"from kokoro_onnx import Kokoro; Kokoro('models/kokoro-v1.0.onnx', 'models/voices-v1.0.bin')\""
        exit 1
    fi
else
    print_success "Kokoro models already exist"
fi
echo ""

# Step 9: Pull Llama 3.2 model
print_info "Checking Llama 3.2 model..."
if command -v ollama &> /dev/null; then
    MODEL_LIST=$(ollama list 2>/dev/null || echo "")
    if echo "$MODEL_LIST" | grep -q "llama3.2"; then
        print_success "Llama 3.2 model already installed"
    else
        print_info "Pulling Llama 3.2 model..."
        print_info "This will download ~1.1GB and take 10-15 minutes..."
        print_info "Make sure Ollama is running in background!"
        echo ""
        read -p "Have you started Ollama? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if ollama pull llama3.2; then
                print_success "Llama 3.2 model installed"
            else
                print_error "Failed to pull Llama 3.2"
                echo "Try manually in another terminal:"
                echo "  ollama pull llama3.2"
            fi
        else
            print_info "Start Ollama with: ollama serve"
            echo "Then run: ollama pull llama3.2"
        fi
    fi
fi
echo ""

# Step 10: Verify installation
print_info "Verifying installation..."
$PYTHON_CMD << EOF
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
EOF

if [ $? -ne 0 ]; then
    print_error "Some packages failed verification"
    exit 1
fi
print_success "All packages verified"
echo ""

# Step 11: Final instructions
print_header "Setup Complete! 🎉"
echo ""
print_success "Installation finished successfully!"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "1. ${YELLOW}Start Ollama${NC} (in another terminal):"
echo "   ${BLUE}ollama serve${NC}"
echo ""
echo "2. ${YELLOW}Activate virtual environment${NC}:"
echo "   ${BLUE}source venv/bin/activate${NC}"
echo ""
echo "3. ${YELLOW}Run the voice assistant${NC}:"
echo "   ${BLUE}python src/voice_assistant.py${NC}"
echo ""
echo -e "${BLUE}Useful links:${NC}"
echo "- Documentation: README.md"
echo "- Installation help: INSTALLATION.md"
echo "- Architecture: ARCHITECTURE.md"
echo "- FAQ: FAQ.md"
echo ""
echo -e "${GREEN}Happy learning! 🚀${NC}"
echo ""
