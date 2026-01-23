# cyminiaudio

Minimal Python bindings for [miniaudio](https://miniaud.io/) (v0.11.21).

A Cython-based audio library providing high-level Python APIs for audio playback, recording, effects processing, and real-time audio applications.

## Features

- **Audio Playback** - High-level engine for sound playback with volume, pan, pitch control
- **3D Spatial Audio** - Position, direction, velocity, distance attenuation, Doppler effect
- **Audio Decoding** - Decode MP3, WAV, FLAC, and other formats to PCM
- **Audio Encoding** - Record and save audio to WAV files
- **Waveform Generation** - Sine, square, triangle, sawtooth waveforms
- **Noise Generation** - White, pink, and brownian noise
- **Audio Filters** - Low-pass, high-pass, band-pass, notch, peak, shelf filters
- **Effects** - Delay with wet/dry/decay control
- **Node Graph** - Build custom audio processing pipelines
- **Resource Manager** - Async audio loading and caching
- **Ring Buffers** - Lock-free buffers for real-time audio
- **Device Enumeration** - List and select audio devices

## Installation

```sh
pip install cyminiaudio
```

To build, requires Python 3.9+ and a C compiler.

```bash
# Clone the repository
git clone https://github.com/user/cyminiaudio.git
cd cyminiaudio

# Install with uv (recommended)
make build

# Or install with pip
pip install .
```

## Quick Start

### Simple Playback

```python
import cyminiaudio
import time

# Create an audio engine and play a sound
with cyminiaudio.Engine() as engine:
    sound = engine.play("music.mp3")
    sound.volume = 0.5
    time.sleep(5)  # Play for 5 seconds
```

### Sound Control

```python
with cyminiaudio.Engine() as engine:
    with cyminiaudio.Sound(engine, "music.mp3") as sound:
        sound.volume = 0.8
        sound.pan = -0.5      # Pan left
        sound.pitch = 1.2     # Higher pitch
        sound.looping = True
        sound.start()
        time.sleep(10)
```

### Waveform Generation

```python
# Generate a sine wave
waveform = cyminiaudio.Waveform(
    waveform_type=cyminiaudio.WaveformType.SINE,
    amplitude=0.5,
    frequency=440.0
)
data = waveform.read(1024)  # Read 1024 frames
```

### Audio Filters

```python
# Apply a low-pass filter
lpf = cyminiaudio.LowPassFilter(cutoff=1000.0, order=2)
waveform = cyminiaudio.Waveform(frequency=440.0)
data = waveform.read(1024)
filtered = lpf.process(data)
```

### Node Graph Processing

```python
# Create a processing graph with filters
with cyminiaudio.NodeGraph(channels=2) as graph:
    lpf = cyminiaudio.LPFNode(graph, cutoff=1000.0)
    delay = cyminiaudio.DelayNode(graph, delay_ms=250.0, decay=0.5)
    # Connect nodes and process audio...
```

### Audio Recording

```python
# Record audio to a WAV file
with cyminiaudio.Encoder("output.wav", channels=2, sample_rate=48000) as encoder:
    waveform = cyminiaudio.Waveform(frequency=440.0)
    for _ in range(100):
        data = waveform.read(1024)
        encoder.write(data)
```

### Device Enumeration

```python
# List available audio devices
devices = cyminiaudio.list_devices()
for dev in devices['playback']:
    print(f"{dev.name} (default: {dev.is_default})")
```

## API Reference

### Core Classes

| Class | Description |
|-------|-------------|
| `Engine` | High-level audio engine for playback |
| `Sound` | Individual sound with full parameter control |
| `Decoder` | Decode audio files to PCM |
| `Encoder` | Encode PCM to audio files |
| `Waveform` | Procedural waveform generator |
| `Noise` | Procedural noise generator |

### Filters

| Class | Description |
|-------|-------------|
| `LowPassFilter` | Attenuates frequencies above cutoff |
| `HighPassFilter` | Attenuates frequencies below cutoff |
| `BandPassFilter` | Passes frequencies within a range |
| `NotchFilter` | Attenuates a specific frequency |
| `PeakFilter` | Peaking EQ for boost/cut |
| `LowShelfFilter` | Boosts/cuts below threshold |
| `HighShelfFilter` | Boosts/cuts above threshold |

### Effects

| Class | Description |
|-------|-------------|
| `Delay` | Audio delay with wet/dry/decay |

### Node Graph

| Class | Description |
|-------|-------------|
| `NodeGraph` | Audio processing graph container |
| `SplitterNode` | Splits audio to multiple outputs |
| `LPFNode` | Low-pass filter node |
| `HPFNode` | High-pass filter node |
| `BPFNode` | Band-pass filter node |
| `DelayNode` | Delay effect node |

### Resource Management

| Class | Description |
|-------|-------------|
| `ResourceManager` | Async audio loading and caching |
| `ResourceDataSource` | Loaded audio data source |
| `RingBuffer` | Lock-free byte buffer |
| `PCMRingBuffer` | Lock-free PCM frame buffer |

### Enums

| Enum | Values |
|------|--------|
| `Format` | U8, S16, S24, S32, F32 |
| `DeviceType` | PLAYBACK, CAPTURE, DUPLEX, LOOPBACK |
| `WaveformType` | SINE, SQUARE, TRIANGLE, SAWTOOTH |
| `NoiseType` | WHITE, PINK, BROWNIAN |
| `AttenuationModel` | NONE, INVERSE, LINEAR, EXPONENTIAL |
| `NodeState` | STARTED, STOPPED |

## Development

```bash
# Install dependencies
make sync

# Build
make build

# Run tests
make test

# Build wheel
make wheel

# Clean build artifacts
make clean
```

## Requirements

- Python 3.9+
- Cython 3.0+
- CMake 3.15+
- C compiler (gcc, clang, MSVC)

### Platform-specific

- **macOS**: CoreAudio, AudioToolbox, CoreFoundation (included in system)
- **Linux**: ALSA or PulseAudio development libraries
- **Windows**: Windows SDK

## License

See LICENSE file.

## See Also

- [miniaudio](https://miniaud.io/) - The underlying C audio library
- [pyminiaudio](https://github.com/irmen/pyminiaudio) - Alternative cffi-based Python bindings
