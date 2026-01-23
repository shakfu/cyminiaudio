"""
cyminiaudio - Minimal Python bindings for miniaudio.

A Python audio library providing:
- High-level audio engine for sound playback
- Sound objects with full parameter control
- Device enumeration
- Waveform and noise generation
- Audio decoding and encoding
- Audio filters and effects
- Ring buffers for real-time audio
- Node graph for custom audio processing
- Resource manager for async loading

Example:
    import cyminiaudio

    # Simple playback
    engine = cyminiaudio.Engine()
    sound = engine.play("music.mp3")
    sound.volume = 0.5

    # Device info
    devices = cyminiaudio.list_devices()
    print(devices['playback'])

    # Audio processing
    lpf = cyminiaudio.LowPassFilter(cutoff=1000.0)
    filtered = lpf.process(audio_data)

    # Node graph
    graph = cyminiaudio.NodeGraph(channels=2)
    lpf_node = cyminiaudio.LPFNode(graph, cutoff=1000.0)
"""

from cyminiaudio._core import (
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
    NodeState,
    PanMode,
    Positioning,
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
    # Data conversion
    LinearResampler,
    ChannelConverter,
    DataConverter,
    # Volume/Panning
    Panner,
    Fader,
    Gainer,
    # 3D Audio / Spatialization
    SpatializerListener,
    Spatializer,
    # Audio buffers
    AudioBuffer,
    # Node graph
    NodeGraph,
    SplitterNode,
    LPFNode,
    HPFNode,
    BPFNode,
    DelayNode,
    NotchNode,
    PeakNode,
    LoShelfNode,
    HiShelfNode,
    BiquadNode,
    # Resource manager
    ResourceManager,
    ResourceDataSource,
    # Sound flags
    SOUND_FLAG_STREAM,
    SOUND_FLAG_DECODE,
    SOUND_FLAG_ASYNC,
    SOUND_FLAG_NO_PITCH,
    SOUND_FLAG_NO_SPATIALIZATION,
    # Resource manager flags
    RESOURCE_MANAGER_FLAG_NON_BLOCKING,
    RESOURCE_MANAGER_DATA_SOURCE_FLAG_STREAM,
    RESOURCE_MANAGER_DATA_SOURCE_FLAG_DECODE,
    RESOURCE_MANAGER_DATA_SOURCE_FLAG_ASYNC,
    RESOURCE_MANAGER_DATA_SOURCE_FLAG_WAIT_INIT,
    # Legacy functions
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
    "NodeState",
    "PanMode",
    "Positioning",
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
    # Data conversion
    "LinearResampler",
    "ChannelConverter",
    "DataConverter",
    # Volume/Panning
    "Panner",
    "Fader",
    "Gainer",
    # 3D Audio / Spatialization
    "SpatializerListener",
    "Spatializer",
    # Audio buffers
    "AudioBuffer",
    # Node graph
    "NodeGraph",
    "SplitterNode",
    "LPFNode",
    "HPFNode",
    "BPFNode",
    "DelayNode",
    "NotchNode",
    "PeakNode",
    "LoShelfNode",
    "HiShelfNode",
    "BiquadNode",
    # Resource manager
    "ResourceManager",
    "ResourceDataSource",
    # Sound flags
    "SOUND_FLAG_STREAM",
    "SOUND_FLAG_DECODE",
    "SOUND_FLAG_ASYNC",
    "SOUND_FLAG_NO_PITCH",
    "SOUND_FLAG_NO_SPATIALIZATION",
    # Resource manager flags
    "RESOURCE_MANAGER_FLAG_NON_BLOCKING",
    "RESOURCE_MANAGER_DATA_SOURCE_FLAG_STREAM",
    "RESOURCE_MANAGER_DATA_SOURCE_FLAG_DECODE",
    "RESOURCE_MANAGER_DATA_SOURCE_FLAG_ASYNC",
    "RESOURCE_MANAGER_DATA_SOURCE_FLAG_WAIT_INIT",
    # Legacy functions
    "play_sine",
    "play_file",
    "engine_play_file",
]

__version__ = "0.1.0"
