# cyminiaudio

Minimal Python bindings for [miniaudio](https://miniaud.io/) (v0.11.24).

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
- **Data Conversion** - Sample rate conversion, channel conversion, format conversion
- **Volume Control** - Panning, fading, gain with smoothing
- **Node Graph** - Build custom audio processing pipelines
- **Resource Manager** - Async audio loading and caching
- **Ring Buffers** - Lock-free buffers for real-time audio
- **Audio Buffers** - In-memory buffers for procedural audio
- **Low-Level Device Access** - Direct device control for advanced use cases
- **Device Enumeration** - List and select audio devices

## Installation

```sh
pip install cyminiaudio
```

To build from source, requires Python 3.9+ and a C compiler.

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
import cyminiaudio as cma
import time

# Create an audio engine and play a sound
with cma.Engine() as engine:
    sound = engine.play("music.mp3")
    sound.volume = 0.5
    time.sleep(5)  # Play for 5 seconds
```

### Sound Control

```python
import cyminiaudio as cma

with cma.Engine() as engine:
    with cma.Sound(engine, "music.mp3") as sound:
        sound.volume = 0.8
        sound.pan = -0.5      # Pan left
        sound.pitch = 1.2     # Higher pitch
        sound.looping = True
        sound.start()
        time.sleep(10)
```

### Waveform Generation

```python
import cyminiaudio as cma

# Generate a sine wave
waveform = cma.Waveform(
    waveform_type=cma.WaveformType.SINE,
    amplitude=0.5,
    frequency=440.0
)
data = waveform.read(1024)  # Read 1024 frames
```

### Audio Filters

```python
import cyminiaudio as cma

# Apply a low-pass filter
lpf = cma.LowPassFilter(cutoff=1000.0, order=2)
waveform = cma.Waveform(frequency=440.0)
data = waveform.read(1024)
filtered = lpf.process(data)
```

### Node Graph Processing

```python
import cyminiaudio as cma

# Create a processing graph with filters
with cma.NodeGraph(channels=2) as graph:
    lpf = cma.LPFNode(graph, cutoff=1000.0)
    delay = cma.DelayNode(graph, delay_ms=250.0, decay=0.5)
    # Connect nodes and process audio...
```

### Audio Recording

```python
import cyminiaudio as cma

# Record audio to a WAV file
with cma.Encoder("output.wav", channels=2, sample_rate=48000) as encoder:
    waveform = cma.Waveform(frequency=440.0)
    for _ in range(100):
        data = waveform.read(1024)
        encoder.write(data)
```

### Data Conversion

```python
import cyminiaudio as cma

# Resample audio from 44100 to 48000 Hz
resampler = cma.LinearResampler(
    sample_rate_in=44100,
    sample_rate_out=48000
)
output = resampler.process(input_data)

# Convert mono to stereo
converter = cma.ChannelConverter(channels_in=1, channels_out=2)
stereo = converter.process(mono_data)
```

### Volume and Panning

```python
import cyminiaudio as cma

# Apply panning
panner = cma.Panner()
panner.pan = -0.5  # Pan left
output = panner.process(data)

# Apply volume with smoothing (avoids clicks)
gainer = cma.Gainer(channels=2)
gainer.set_gain(0.5)
output = gainer.process(data)

# Convert between linear and dB
db = cma.volume_linear_to_db(0.5)  # -6.02 dB
linear = cma.volume_db_to_linear(-6.0)  # ~0.5
```

### 3D Spatial Audio

```python
import cyminiaudio as cma

# Create a spatializer for 3D audio
listener = cma.SpatializerListener(channels=2)
listener.position = (0.0, 0.0, 0.0)
listener.direction = (0.0, 0.0, -1.0)

spatializer = cma.Spatializer(channels=2, listener=listener)
spatializer.position = (5.0, 0.0, -3.0)  # Sound position
output = spatializer.process(input_data)
```

### Device Enumeration

```python
# List available audio devices
devices = cyminiaudio.list_devices()
for dev in devices['playback']:
    print(f"{dev.name} (default: {dev.is_default})")
```

### Low-Level Device Access

```python
# Direct device access for advanced use cases
with cyminiaudio.Device(
    device_type=cyminiaudio.DeviceType.PLAYBACK,
    sample_rate=48000,
    period_size_ms=20
) as device:
    device.start()
    # ... handle audio callbacks ...
    device.stop()
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

### Data Conversion

| Class | Description |
|-------|-------------|
| `LinearResampler` | Sample rate conversion |
| `ChannelConverter` | Channel count conversion (mono/stereo) |
| `DataConverter` | General format/rate/channel conversion |

### Volume and Panning

| Class | Description |
|-------|-------------|
| `Panner` | Stereo panning control |
| `Fader` | Volume fading over time |
| `Gainer` | Gain control with smoothing |

### 3D Audio / Spatialization

| Class | Description |
|-------|-------------|
| `SpatializerListener` | Listener position/orientation |
| `Spatializer` | 3D audio positioning and attenuation |

### Audio Buffers

| Class | Description |
|-------|-------------|
| `AudioBuffer` | In-memory audio buffer |
| `AudioBufferRef` | Non-owning reference to audio data |
| `PagedAudioBuffer` | Large audio buffer with paged memory |

### Low-Level Device Access

| Class | Description |
|-------|-------------|
| `Device` | Direct audio device access |
| `Context` | Device context for enumeration |

### Node Graph

| Class | Description |
|-------|-------------|
| `NodeGraph` | Audio processing graph container |
| `SplitterNode` | Splits audio to multiple outputs |
| `LPFNode` | Low-pass filter node |
| `HPFNode` | High-pass filter node |
| `BPFNode` | Band-pass filter node |
| `DelayNode` | Delay effect node |
| `NotchNode` | Notch filter node |
| `PeakNode` | Peak EQ node |
| `LoShelfNode` | Low shelf filter node |
| `HiShelfNode` | High shelf filter node |
| `BiquadNode` | Generic biquad filter node |
| `DataSourceNode` | Data source as graph node |

### Resource Management

| Class | Description |
|-------|-------------|
| `ResourceManager` | Async audio loading and caching |
| `ResourceDataSource` | Loaded audio data source |
| `RingBuffer` | Lock-free byte buffer |
| `PCMRingBuffer` | Lock-free PCM frame buffer |

### Utility Functions

| Function | Description |
|----------|-------------|
| `get_version()` | Get miniaudio version string |
| `list_devices()` | List available audio devices |
| `get_default_device()` | Get default playback/capture device |
| `volume_linear_to_db()` | Convert linear volume to decibels |
| `volume_db_to_linear()` | Convert decibels to linear volume |
| `copy_pcm_frames()` | Copy PCM frames between buffers |
| `mix_pcm_frames_f32()` | Mix PCM frames with volume |
| `apply_volume_factor_pcm_frames()` | Apply volume in-place |
| `copy_and_apply_volume_factor_pcm_frames()` | Copy and apply volume |

### Enums

| Enum | Values |
|------|--------|
| `Format` | U8, S16, S24, S32, F32 |
| `DeviceType` | PLAYBACK, CAPTURE, DUPLEX, LOOPBACK |
| `WaveformType` | SINE, SQUARE, TRIANGLE, SAWTOOTH |
| `NoiseType` | WHITE, PINK, BROWNIAN |
| `AttenuationModel` | NONE, INVERSE, LINEAR, EXPONENTIAL |
| `NodeState` | STARTED, STOPPED |
| `PanMode` | BALANCE, PAN |
| `Positioning` | ABSOLUTE, RELATIVE |

## Development

```bash
# Install dependencies
make sync

# Build
make build

# Run tests
make test

# Run all QA checks (test, lint, typecheck, format)
make qa

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
- **Linux**: ALSA development libraries (`libasound2-dev` on Debian/Ubuntu)
- **Windows**: Windows SDK

## License

See LICENSE file.

## See Also

- [miniaudio](https://miniaud.io/) - The underlying C audio library (v0.11.24)
- [pyminiaudio](https://github.com/irmen/pyminiaudio) - Alternative cffi-based Python bindings
