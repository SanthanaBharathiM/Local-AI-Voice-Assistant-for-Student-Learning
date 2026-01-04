"""
Kokoro TTS Service Wrapper

Integrates Kokoro ONNX-based Text-to-Speech with Pipecat framework.
Provides natural, supportive voice for student learning.
"""

import asyncio
import numpy as np
import os
from typing import Optional

from pipecat.frames.frames import OutputAudioRawFrame
from pipecat.services.tts_service import TTSService

from kokoro_onnx import Kokoro


class KokoroTTSService(TTSService):
    """
    Kokoro TTS Service for high-quality, natural voice synthesis.
    
    Features:
    - Natural, warm voice ("af_heart")
    - ONNX inference (CPU compatible)
    - Async-safe (non-blocking)
    - Low memory footprint (~512MB)
    
    Usage:
        tts = KokoroTTSService(
            model_path="models/kokoro-v1.0.onnx",
            voice_path="models/voices-v1.0.bin"
        )
        
        async for frame in tts.run_tts("Hello, how are you?"):
            # Frame contains audio output
            yield frame
    """
    
    SUPPORTED_VOICES = {
        "af_heart": "Supportive female (default)",
        "am_adam": "Calm male",
        "bf_emma": "Warm female",
        "bm_george": "Friendly male"
    }
    
    SUPPORTED_LANGUAGES = {
        "en-us": "English (US)",
        "en-gb": "English (UK)"
    }

    def __init__(
        self,
        model_path: str = "models/kokoro-v1.0.onnx",
        voice_path: str = "models/voices-v1.0.bin",
        voice: str = "af_heart",
        speed: float = 1.0,
        lang: str = "en-us",
        **kwargs
    ):
        """
        Initialize Kokoro TTS Service.
        
        Args:
            model_path: Path to Kokoro ONNX model
            voice_path: Path to voice weights
            voice: Voice preset (see SUPPORTED_VOICES)
            speed: Speech speed (0.5-2.0, default 1.0)
            lang: Language code (default "en-us")
            **kwargs: Additional arguments for TTSService
        """
        super().__init__(**kwargs)
        
        # Validate parameters
        if voice not in self.SUPPORTED_VOICES:
            raise ValueError(
                f"Unsupported voice: {voice}. "
                f"Choose from: {list(self.SUPPORTED_VOICES.keys())}"
            )
        
        if lang not in self.SUPPORTED_LANGUAGES:
            raise ValueError(
                f"Unsupported language: {lang}. "
                f"Choose from: {list(self.SUPPORTED_LANGUAGES.keys())}"
            )
        
        if not (0.5 <= speed <= 2.0):
            raise ValueError("Speed must be between 0.5 and 2.0")
        
        # Store parameters
        self.voice = voice
        self.speed = speed
        self.lang = lang
        
        # Load Kokoro model
        print("🎙️ Loading Kokoro ONNX TTS...")
        try:
            self.tts = Kokoro(model_path, voice_path)
            print("✅ Kokoro TTS ready!")
        except Exception as e:
            print(f"❌ Failed to load Kokoro: {e}")
            print("Make sure models are downloaded:")
            print(f"  - {model_path}")
            print(f"  - {voice_path}")
            raise

    async def run_tts(self, text: str) -> None:
        """
        Main TTS entry point. Called by Pipecat pipeline.
        
        Args:
            text: Text to synthesize to speech
            
        Yields:
            OutputAudioRawFrame containing synthesized audio
        """
        if not text or not text.strip():
            print("⚠️  Empty text provided to TTS")
            return
        
        print(f"🔊 Synthesizing: {text[:50]}...")
        
        try:
            async for frame in self._synthesize(text):
                yield frame
        except Exception as e:
            print(f"❌ TTS Error: {e}")
            raise

    async def _synthesize(self, text: str):
        """
        Synthesize text to speech using Kokoro.
        
        This method:
        1. Runs blocking TTS in thread (non-blocking)
        2. Normalizes audio to proper format
        3. Yields audio frames for pipeline
        
        Args:
            text: Text to synthesize
            
        Yields:
            OutputAudioRawFrame with audio data
        """
        try:
            # Run blocking TTS creation in background thread
            # This keeps event loop responsive (can capture next audio input)
            samples, sample_rate = await asyncio.to_thread(
                self.tts.create,
                text,
                voice=self.voice,
                speed=self.speed,
                lang=self.lang
            )
            
            # Ensure samples is numpy array
            if not isinstance(samples, np.ndarray):
                samples = np.array(samples)
            
            # ⚠️  CRITICAL: Normalize audio to int16 range
            # Without this step:
            # - Audio plays at wrong volume
            # - Severe distortion/crackling
            # - Pitch sounds wrong
            #
            # Normalization process:
            # 1. Kokoro outputs float32 in range [-1.0, 1.0]
            # 2. Convert to int16 by scaling: [-32768, 32767]
            # 3. This is standard PCM audio format
            
            # Clamp values to [-1.0, 1.0] before scaling
            samples = np.clip(samples, -1.0, 1.0)
            
            # Scale and convert to int16
            audio_int16 = (samples * 32767).astype(np.int16)
            
            # Emit audio frame to pipeline
            # OutputAudioRawFrame expects:
            # - audio: bytes (PCM data)
            # - sample_rate: int (Hz)
            # - num_channels: int (mono=1, stereo=2)
            yield OutputAudioRawFrame(
                audio=audio_int16.tobytes(),
                sample_rate=24000,  # Kokoro outputs 24kHz
                num_channels=1       # Mono audio
            )
            
            # Log synthesis completion
            duration_seconds = len(samples) / 24000
            print(f"✅ Synthesized {duration_seconds:.1f}s audio")
            
        except Exception as e:
            print(f"❌ TTS Error during synthesis: {e}")
            print(f"   Text: {text}")
            print(f"   Voice: {self.voice}")
            print(f"   Speed: {self.speed}")
            raise

    def get_info(self) -> dict:
        """
        Return TTS service information.
        
        Returns:
            Dictionary with service metadata
        """
        return {
            "name": "Kokoro ONNX TTS",
            "version": "1.0",
            "voice": self.voice,
            "speed": self.speed,
            "language": self.lang,
            "sample_rate": 24000,
            "supported_voices": list(self.SUPPORTED_VOICES.keys()),
            "supported_languages": list(self.SUPPORTED_LANGUAGES.keys())
        }


# Example usage and testing
if __name__ == "__main__":
    import asyncio
    
    async def test_kokoro():
        """Test Kokoro TTS independently."""
        
        # Initialize TTS
        tts = KokoroTTSService(
            model_path="models/kokoro-v1.0.onnx",
            voice_path="models/voices-v1.0.bin",
            voice="af_heart",
            speed=1.0
        )
        
        # Test synthesis
        test_text = "Hello! I am your learning assistant. How can I help you today?"
        
        print("\n🎙️ Testing Kokoro TTS...")
        print(f"Text: {test_text}")
        print(f"Voice: af_heart")
        print(f"Speed: 1.0x")
        print()
        
        async for frame in tts.run_tts(test_text):
            print(f"Generated frame with {len(frame.audio)} bytes of audio")
            # In real usage, frame would be played to speaker
        
        print("\n✅ Test complete!")
