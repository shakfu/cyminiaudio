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
    RESOURCE_MANAGER_DATA_SOURCE_FLAG_ASYNC,
    RESOURCE_MANAGER_DATA_SOURCE_FLAG_DECODE,
    RESOURCE_MANAGER_DATA_SOURCE_FLAG_STREAM,
    RESOURCE_MANAGER_DATA_SOURCE_FLAG_WAIT_INIT,
    # Resource manager flags
    RESOURCE_MANAGER_FLAG_NON_BLOCKING,
    SOUND_FLAG_ASYNC,
    SOUND_FLAG_DECODE,
    SOUND_FLAG_NO_PITCH,
    SOUND_FLAG_NO_SPATIALIZATION,
    # Sound flags
    SOUND_FLAG_STREAM,
    AttenuationModel,
    # Audio buffers
    AudioBuffer,
    AudioBufferRef,
    BandPassFilter,
    BiquadNode,
    BPFNode,
    ChannelConverter,
    Context,
    DataConverter,
    DataSourceNode,
    Decoder,
    DecoderError,
    # Effects
    Delay,
    DelayNode,
    # Low-level device access
    Device,
    DeviceError,
    # Device enumeration
    DeviceInfo,
    DeviceType,
    Encoder,
    EncodingFormat,
    # Core classes
    Engine,
    EngineError,
    Fader,
    # Enums
    Format,
    Gainer,
    HighPassFilter,
    HighShelfFilter,
    HiShelfNode,
    HPFNode,
    # Data conversion
    LinearResampler,
    LoShelfNode,
    # Filters
    LowPassFilter,
    LowShelfFilter,
    LPFNode,
    # Exceptions
    MinimaError,
    # Node graph
    NodeGraph,
    NodeState,
    Noise,
    NoiseType,
    NotchFilter,
    NotchNode,
    PagedAudioBuffer,
    PanMode,
    # Volume/Panning
    Panner,
    PCMRingBuffer,
    PeakFilter,
    PeakNode,
    Positioning,
    ResourceDataSource,
    # Resource manager
    ResourceManager,
    # Ring buffers
    RingBuffer,
    Sound,
    SoundError,
    Spatializer,
    # 3D Audio / Spatialization
    SpatializerListener,
    SplitterNode,
    Waveform,
    WaveformType,
    apply_volume_factor_pcm_frames,
    apply_volume_factor_pcm_frames_f32,
    copy_and_apply_volume_factor_pcm_frames,
    copy_and_apply_volume_factor_pcm_frames_f32,
    # PCM utility functions
    copy_pcm_frames,
    engine_play_file,
    get_default_device,
    # Version
    get_version,
    get_version_numbers,
    list_devices,
    mix_pcm_frames_f32,
    play_file,
    # Legacy functions
    play_sine,
    volume_db_to_linear,
    # Volume utility functions
    volume_linear_to_db,
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
    "AudioBufferRef",
    "PagedAudioBuffer",
    # Low-level device access
    "Device",
    "Context",
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
    "DataSourceNode",
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
    # PCM utility functions
    "copy_pcm_frames",
    "mix_pcm_frames_f32",
    # Volume utility functions
    "volume_linear_to_db",
    "volume_db_to_linear",
    "apply_volume_factor_pcm_frames",
    "copy_and_apply_volume_factor_pcm_frames",
    "apply_volume_factor_pcm_frames_f32",
    "copy_and_apply_volume_factor_pcm_frames_f32",
    # Legacy functions
    "play_sine",
    "play_file",
    "engine_play_file",
]

__version__ = "0.1.1"
