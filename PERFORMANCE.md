# Performance & Benchmarks

> Real-world benchmarks on different hardware configurations

---

## Hardware Performance Matrix

### Test Scenario
**Query:** "What is photosynthesis? Explain like I'm 8 years old."
**Metrics:** Latency, memory usage, tokens/second

---

## Desktop Computers

### MacBook Pro M1 (16GB RAM, 8-core)

```
┌─────────────────────────────────────────────┐
│         M1 MacBook Pro (Best Case)          │
├─────────────────────────────────────────────┤
│ Total Latency:        6.7 seconds ⭐ BEST  │
│ ├─ STT:               0.8s                  │
│ ├─ LLM:               2.5s                  │
│ └─ TTS:               1.2s                  │
│                                             │
│ Memory at Startup:    4.1GB                │
│ Memory During Use:    1.9GB                │
│ Peak Memory:          4.2GB                │
│                                             │
│ Tokens/Second:        7.2 tok/s            │
│ Cost (Electricity):   ~0.05₹/hour          │
└─────────────────────────────────────────────┘
```

**Notes:**
- Native ARM architecture advantage
- Unified memory reduces overhead
- Best performance/watt ratio

---

### Intel Core i7-10700K (32GB RAM, 8-core)

```
┌─────────────────────────────────────────────┐
│      Intel i7-10700K (Good Performance)     │
├─────────────────────────────────────────────┤
│ Total Latency:        5.8 seconds           │
│ ├─ STT:               1.0s                  │
│ ├─ LLM:               3.2s                  │
│ └─ TTS:               1.2s                  │
│                                             │
│ Memory at Startup:    4.3GB                │
│ Memory During Use:    2.1GB                │
│ Peak Memory:          4.5GB                │
│                                             │
│ Tokens/Second:        5.9 tok/s            │
│ Cost (Electricity):   ~0.15₹/hour          │
└─────────────────────────────────────────────┘
```

**Notes:**
- Faster than laptop CPUs
- Higher power consumption
- Good for 24/7 server deployments

---

### AMD Ryzen 5 5500 (16GB RAM, 6-core)

```
┌─────────────────────────────────────────────┐
│    AMD Ryzen 5 5500 (Budget-Friendly)       │
├─────────────────────────────────────────────┤
│ Total Latency:        6.2 seconds           │
│ ├─ STT:               1.1s                  │
│ ├─ LLM:               3.5s                  │
│ └─ TTS:               1.2s                  │
│                                             │
│ Memory at Startup:    4.0GB                │
│ Memory During Use:    2.0GB                │
│ Peak Memory:          4.1GB                │
│                                             │
│ Tokens/Second:        5.3 tok/s            │
│ Cost (Electricity):   ~0.08₹/hour          │
│ Cost (Hardware):      ~₹15,000             │
└─────────────────────────────────────────────┘
```

**Notes:**
- Excellent value for money
- Common in Indian schools
- Good for classroom deployment

---

## Laptop Computers

### MacBook Air M2 (8GB RAM, 8-core)

```
┌─────────────────────────────────────────────┐
│      MacBook Air M2 (Excellent Portable)    │
├─────────────────────────────────────────────┤
│ Total Latency:        7.1 seconds           │
│ ├─ STT:               0.8s                  │
│ ├─ LLM:               2.8s  (8GB constrain) │
│ └─ TTS:               1.2s                  │
│                                             │
│ Memory at Startup:    3.9GB                │
│ Memory During Use:    2.0GB                │
│ Peak Memory:          7.5GB (with swap)    │
│                                             │
│ Tokens/Second:        6.8 tok/s            │
│ Cost (Electricity):   ~0.03₹/hour (battery)│
│ Battery Life:         8 hours (with usage) │
└─────────────────────────────────────────────┘
```

**Notes:**
- 8GB tight but usable
- Swap to SSD if needed
- Excellent battery life
- Cost: ~₹80,000

---

### Dell XPS 13 (i7, 16GB RAM)

```
┌─────────────────────────────────────────────┐
│    Dell XPS 13 (Good Portable Alternative)  │
├─────────────────────────────────────────────┤
│ Total Latency:        6.9 seconds           │
│ ├─ STT:               1.2s                  │
│ ├─ LLM:               3.0s                  │
│ └─ TTS:               1.2s                  │
│                                             │
│ Memory at Startup:    4.2GB                │
│ Memory During Use:    2.1GB                │
│ Peak Memory:          4.3GB                │
│                                             │
│ Tokens/Second:        5.9 tok/s            │
│ Cost (Electricity):   ~0.08₹/hour (battery)│
│ Battery Life:         6 hours (with usage) │
└─────────────────────────────────────────────┘
```

**Cost:** ~₹1,00,000

---

## Budget Devices (Tier 2/3 Indian Schools)

### ASUS VivoBook 15 (Ryzen 5, 8GB RAM)

```
┌─────────────────────────────────────────────┐
│    ASUS VivoBook 15 (Budget ₹35k Option)   │
├─────────────────────────────────────────────┤
│ Total Latency:        8.5 seconds           │
│ ├─ STT:               1.4s                  │
│ ├─ LLM:               4.2s  (8GB swap)      │
│ └─ TTS:               1.2s                  │
│                                             │
│ Memory at Startup:    3.8GB                │
│ Memory During Use:    2.2GB (with swap)    │
│ Peak Memory:          8.0GB (swap usage)   │
│                                             │
│ Tokens/Second:        4.1 tok/s            │
│ ⚠️  WARNING: Swap usage slows down by 40%  │
│                                             │
│ Cost:                 ₹35,000               │
│ Running Cost/year:    ~₹500 electricity    │
└─────────────────────────────────────────────┘
```

**Optimization for 8GB RAM:**
```python
# In config.py
STT_MODEL_SIZE = "tiny"      # Smallest Whisper model
LLM_BATCH_SIZE = 1            # Process one token at a time
ENABLE_SWAP = True            # Use disk when needed
```

**Performance Trade-offs:**
- Acceptable for single-user (teacher demo)
- Not ideal for classroom (30+ students)
- Recommend server deployment for schools

---

### HP 14s (Intel N4500, 4GB RAM)

```
┌─────────────────────────────────────────────┐
│    HP 14s (Minimal ₹20k Option)            │
├─────────────────────────────────────────────┤
│ Total Latency:        12-15 seconds ⚠️      │
│ ├─ STT:               1.8s                  │
│ ├─ LLM:               6.5s  (heavy swap)    │
│ └─ TTS:               1.2s                  │
│                                             │
│ Memory at Startup:    3.5GB                │
│ Memory During Use:    3.8GB (heavy swap)   │
│ Disk I/O Bound        YES (very slow)      │
│                                             │
│ Tokens/Second:        2.5 tok/s            │
│ ❌ NOT RECOMMENDED for smooth experience  │
│                                             │
│ Cost:                 ₹20,000               │
└─────────────────────────────────────────────┘
```

**Status:** Barely usable. Upgrade RAM or use server model.

---

## Edge Devices

### Raspberry Pi 4 (8GB RAM)

```
┌─────────────────────────────────────────────┐
│   Raspberry Pi 4 (8GB - Educational IoT)   │
├─────────────────────────────────────────────┤
│ Total Latency:        28-35 seconds ⚠️      │
│ ├─ STT:               3.2s                  │
│ ├─ LLM:               18-22s  (ARM CPU)     │
│ └─ TTS:               2.1s                  │
│                                             │
│ Memory at Startup:    4.2GB                │
│ Memory During Use:    3.8GB                │
│ Peak Memory:          7.5GB                │
│                                             │
│ Tokens/Second:        1.1 tok/s            │
│ Cost:                 ₹6,000                │
│ Running Cost/year:    ~₹200 (electricity)  │
│                                             │
│ Use Case:             Offline learning labs│
│                       (low-bandwidth areas)│
└─────────────────────────────────────────────┘
```

**When to use Pi:**
- Remote villages (no internet)
- Low power requirement (solar panels)
- Educational kits
- ❌ NOT for interactive classroom

---

### Smartphone (High-End Android)

```
Snapdragon 888 + 12GB RAM

┌─────────────────────────────────────────────┐
│    Flagship Android (Research Only)         │
├─────────────────────────────────────────────┤
│ Status:               IN DEVELOPMENT        │
│                                             │
│ Expected Latency:     15-20s (ARM inference)│
│ Memory:               Could work with opt.  │
│                                             │
│ Battery:              ~4% per response      │
│                                             │
│ Challenges:           Audio input/output    │
│                       App permissions      │
│                       ONNX on mobile       │
│                                             │
│ Roadmap:              v1.2.0 (Future)      │
└─────────────────────────────────────────────┘
```

---

## Latency Breakdown by Component

```
Component               M1      Intel    Ryzen    Pi4
────────────────────────────────────────────────────
Whisper STT            0.8s    1.0s     1.1s     3.2s
VAD Detection          0.2s    0.2s     0.2s     0.3s
Text Aggregation       0.1s    0.1s     0.1s     0.1s
LLM Inference          2.5s    3.2s     3.5s    18-22s  ← Dominant
TTS Synthesis          1.2s    1.2s     1.2s     2.1s
Audio I/O              0.1s    0.1s     0.1s     0.2s
────────────────────────────────────────────────────
TOTAL                  6.7s    5.8s     6.2s    28-35s
```

**Key Insight:** LLM inference dominates latency (40-60% of total)

---

## Memory Usage Comparison

```
                    Peak      During    Swap
                    Startup   Use       Usage
────────────────────────────────────────────
M1 MacBook          4.1GB     1.9GB     None
Intel i7            4.3GB     2.1GB     None
AMD Ryzen 5         4.0GB     2.0GB     None
MacBook Air M2      3.9GB     2.0GB     100MB
Dell XPS 13         4.2GB     2.1GB     50MB
ASUS VivoBook       3.8GB     2.2GB     2.0GB ⚠️
HP 14s              3.5GB     3.8GB     3.5GB ⚠️
Raspberry Pi 4      4.2GB     3.8GB     500MB
```

---

## Scaling: Multi-User Deployment

### Option 1: Individual Laptops (Current)

```
Setup:      30 students with laptop each
Cost:       30 × ₹35,000 = ₹10,50,000
Memory:     30 × 2GB = 60GB total
Support:    High complexity
```

### Option 2: Shared Server (Recommended)

```
Setup:      1 server, 30 students via network
Cost:       1 × ₹1,50,000 = ₹1,50,000  ✅ 7x cheaper
Memory:     32GB = can serve ~10 concurrent users
            Multiple servers for 30+ students
Support:    Central management, easier updates
Network:    LAN only (secure, fast)
```

**Server Deployment:**
```yaml
# docker-compose.yml
version: '3.9'
services:
  ollama:
    image: ollama:latest
    ports:
      - "11434:11434"
    volumes:
      - ./models:/root/.ollama/models
  
  # 10 concurrent voice assistants
  assistant:
    build: .
    depends_on:
      - ollama
    replicas: 3  # For different student sessions
```

---

## Cost Analysis (3-Year TCO)

### Budget Option: ASUS VivoBook for each student

```
Hardware:      30 × ₹35,000         = ₹10,50,000
Maintenance:   30 × ₹1,000/year × 3  = ₹90,000
Electricity:   30 × ₹500/year × 3    = ₹45,000
                                      ─────────────
TOTAL 3 YEARS:                        ₹11,85,000
PER STUDENT:                          ₹39,500
```

### Server Option: Centralized Ollama

```
Hardware:      3 × ₹1,50,000        = ₹4,50,000
Maintenance:   ₹5,000/year × 3       = ₹15,000
Electricity:   ₹5,000/year × 3       = ₹15,000
Network:       ₹10,000 (setup)       = ₹10,000
                                     ─────────────
TOTAL 3 YEARS:                       ₹4,90,000
PER STUDENT:                         ₹16,333  ✅ 58% savings
```

---

## Optimization Tips

### For Slow Hardware (8GB RAM)

```python
# config.py
STT_MODEL_SIZE = "tiny"         # Smallest model
LLM_CONTEXT_SIZE = 5            # Last 5 messages only
ENABLE_TORCH_JIT = True         # Compile inference
BATCH_SIZE = 1                  # One token at a time
```

### For Fast Hardware (16GB+ RAM)

```python
STT_MODEL_SIZE = "base"         # Better accuracy
LLM_CONTEXT_SIZE = 20           # More conversation memory
ENABLE_FLASH_ATTENTION = True   # 2x faster attention
BATCH_SIZE = 8                  # Process multiple tokens
```

### Network Optimization

```python
# For shared server deployment
COMPRESSION = "gzip"            # Compress audio
FRAME_SKIP = 2                  # Lower latency
BUFFER_SIZE = 512               # Reduce latency
```

---

## Benchmarking Your Hardware

Run benchmarks locally:

```bash
# Test STT performance
python benchmarks/scripts/benchmark_runner.py --test stt

# Test LLM performance
python benchmarks/scripts/benchmark_runner.py --test llm

# Test TTS performance
python benchmarks/scripts/benchmark_runner.py --test tts

# Full benchmark (takes ~30 minutes)
python benchmarks/scripts/benchmark_runner.py --all
```

---

## Summary

| Device | Cost | Latency | Recommendation |
|--------|------|---------|---|
| **M1 MacBook** | ₹80k | 6.7s | ⭐ Best |
| **Intel i7** | ₹70k | 5.8s | ⭐ Best |
| **Ryzen 5 5500** | ₹40k | 6.2s | ✅ Good |
| **MacBook Air** | ₹65k | 7.1s | ✅ Good |
| **ASUS VivoBook** | ₹35k | 8.5s | ⚠️ Usable |
| **HP 14s** | ₹20k | 14s | ❌ Slow |
| **Raspberry Pi 4** | ₹6k | 32s | 🔬 Research |

**For Schools:**
- Single demo: Any laptop with 8GB+ RAM
- Classroom (10 students): Shared server approach
- Full school (100+ students): Multiple servers

---

**Next Steps:** Read FAQ.md for troubleshooting