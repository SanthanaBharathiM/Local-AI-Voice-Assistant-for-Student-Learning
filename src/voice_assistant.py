import asyncio
import sys
import numpy as np
import os

from pipecat.frames.frames import EndFrame, OutputAudioRawFrame, TextFrame

from pipecat.pipeline.pipeline import Pipeline
from pipecat.pipeline.runner import PipelineRunner
from pipecat.pipeline.task import PipelineTask

from pipecat.services.tts_service import TTSService
from pipecat.services.ollama.llm import OLLamaLLMService
from pipecat.services.whisper.stt import WhisperSTTService

from pipecat.transports.local.audio import LocalAudioTransport, LocalAudioTransportParams
from pipecat.audio.vad.silero import SileroVADAnalyzer

from pipecat.processors.aggregators.llm_response import (
    LLMUserContextAggregator,
    LLMAssistantContextAggregator,
)
from pipecat.processors.aggregators.openai_llm_context import OpenAILLMContext

from kokoro_onnx import Kokoro

os.environ["HF_HUB_DISABLE_SYMLINKS_WARNING"] = "1"

class KokoroTTSService(TTSService):
    def __init__(self, model_path="kokoro-v1.0.onnx", voice_path="voices-v1.0.bin", **kwargs):
        super().__init__(**kwargs)
        print("🎙️ Loading Kokoro ONNX TTS...")
        self.tts = Kokoro(model_path, voice_path)
        print("✅ Ready!")

    # Fixed: Pipecat expects run_tts to be an async generator
    async def run_tts(self, text: str):
        print(f"🔊 Synthesizing: {text[:30]}...")
        async for frame in self._synthesize(text):
            yield frame

    async def _synthesize(self, text: str):
        try:
            # Run the blocking TTS creation in a thread to keep the loop free
            samples, _ = await asyncio.to_thread(
                self.tts.create,
                text,
                voice="af_heart",
                speed=1.0,
                lang="en-us"
            )
            
            if not isinstance(samples, np.ndarray):
                samples = np.array(samples)
            
            # Normalize and convert to int16
            audio_int16 = (samples * 32767).astype(np.int16)
            
            # Yield the audio frame back to the pipeline
            yield OutputAudioRawFrame(
                audio=audio_int16.tobytes(),
                sample_rate=24000,
                num_channels=1
            )
            
        except Exception as e:
            print(f"❌ TTS Error: {e}")

SYSTEM_PROMPT = (
    "You are a patient and supportive Teaching Assistant. "
    "Your goal is to help students who struggle with reading by explaining concepts simply. "
    "Always use encouraging language. Keep explanations short (1-3 sentences). "
    "If a student is confused, use an analogy or a simple example."
)

context = OpenAILLMContext([{"role": "system", "content": SYSTEM_PROMPT}])
user_aggregator = LLMUserContextAggregator(context=context)
assistant_aggregator = LLMAssistantContextAggregator(context=context)

async def main():
    # Audio Transport Configuration
    transport = LocalAudioTransport(
        LocalAudioTransportParams(
            audio_in_enabled=True,
            audio_out_enabled=True,
            audio_in_sample_rate=16000,
            audio_out_sample_rate=24000,
            vad_analyzer=SileroVADAnalyzer(),
        )
    )

    # Services
    llm = OLLamaLLMService(model="llama3.2", base_url="http://localhost:11434/v1")
    tts = KokoroTTSService(model_path="kokoro-v1.0.onnx", voice_path="voices-v1.0.bin")
    stt = WhisperSTTService(
        model_size="tiny",
        device="cpu",
        compute_type="int8",
    )

    # The Pipeline
    pipeline = Pipeline([
        transport.input(),      # Capture Mic
        stt,                    # Voice -> Text
        user_aggregator,        # Accumulate Text
        llm,                    # Get AI Response
        tts,                    # AI Text -> Audio Frames
        transport.output(),     # Play Audio
        assistant_aggregator,   # Save AI response to memory
    ])

    task = PipelineTask(pipeline)

    @transport.event_handler("on_stop")
    async def on_stop(*args, **kwargs):
        await task.queue_frame(EndFrame())

    print("\n🎙️ TEACHING ASSISTANT ONLINE")
    print("✅ System Ready. Listening for your voice...")

    runner = PipelineRunner()
    await runner.run(task)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n✅ Shutting down...")
        sys.exit(0)