"""
minima - Minimal Python bindings for miniaudio.

A Python audio library providing:
- High-level audio engine for sound playback
- Sound objects with full parameter control
- Device enumeration
- Waveform and noise generation
- Audio decoding and encoding
- Audio filters and effects
- Ring buffers for real-time audio

Example:
    import minima

    # Simple playback
    engine = minima.Engine()
    sound = engine.play("music.mp3")
    sound.volume = 0.5

    # Device info
    devices = minima.list_devices()
    print(devices['playback'])

    # Audio processing
    lpf = minima.LowPassFilter(cutoff=1000.0)
    filtered = lpf.process(audio_data)
"""

from minima._core import (
    # Version
    get_version,
    get_version_numbers,

    # Exceptions
    MinimaError,
    DeviceError,
    DecoderError,
    EngineError,
    SoundError,

    # Enums
    Format,
    DeviceType,
    WaveformType,
    NoiseType,
    AttenuationModel,
    EncodingFormat,

    # Device enumeration
    DeviceInfo,
    list_devices,
    get_default_device,

    # Core classes
    Engine,
    Sound,
    Decoder,
    Encoder,
    Waveform,
    Noise,

    # Filters
    LowPassFilter,
    HighPassFilter,
    BandPassFilter,
    NotchFilter,
    PeakFilter,
    LowShelfFilter,
    HighShelfFilter,

    # Effects
    Delay,

    # Ring buffers
    RingBuffer,
    PCMRingBuffer,

    # Sound flags
    SOUND_FLAG_STREAM,
    SOUND_FLAG_DECODE,
    SOUND_FLAG_ASYNC,
    SOUND_FLAG_NO_PITCH,
    SOUND_FLAG_NO_SPATIALIZATION,

    # Legacy functions (for backwards compatibility)
    play_sine,
    play_file,
    engine_play_file,
)

__all__ = [
    # Version
    "get_version",
    "get_version_numbers",

    # Exceptions
    "MinimaError",
    "DeviceError",
    "DecoderError",
    "EngineError",
    "SoundError",

    # Enums
    "Format",
    "DeviceType",
    "WaveformType",
    "NoiseType",
    "AttenuationModel",
    "EncodingFormat",

    # Device enumeration
    "DeviceInfo",
    "list_devices",
    "get_default_device",

    # Core classes
    "Engine",
    "Sound",
    "Decoder",
    "Encoder",
    "Waveform",
    "Noise",

    # Filters
    "LowPassFilter",
    "HighPassFilter",
    "BandPassFilter",
    "NotchFilter",
    "PeakFilter",
    "LowShelfFilter",
    "HighShelfFilter",

    # Effects
    "Delay",

    # Ring buffers
    "RingBuffer",
    "PCMRingBuffer",

    # Sound flags
    "SOUND_FLAG_STREAM",
    "SOUND_FLAG_DECODE",
    "SOUND_FLAG_ASYNC",
    "SOUND_FLAG_NO_PITCH",
    "SOUND_FLAG_NO_SPATIALIZATION",

    # Legacy functions
    "play_sine",
    "play_file",
    "engine_play_file",
]

__version__ = "0.1.0"
