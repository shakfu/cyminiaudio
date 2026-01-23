# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Filters
- `LowPassFilter` - Attenuates frequencies above cutoff
- `HighPassFilter` - Attenuates frequencies below cutoff
- `BandPassFilter` - Passes frequencies within a range
- `NotchFilter` - Attenuates a specific frequency (band-reject)
- `PeakFilter` - Peaking EQ for boosting/cutting specific frequencies
- `LowShelfFilter` - Boosts/cuts frequencies below threshold
- `HighShelfFilter` - Boosts/cuts frequencies above threshold

#### Effects
- `Delay` - Audio delay effect with wet/dry/decay control

#### Ring Buffers
- `RingBuffer` - Lock-free ring buffer for raw bytes
- `PCMRingBuffer` - Lock-free ring buffer for PCM frames

#### Encoder
- `Encoder` - Audio file encoder for recording (WAV format)
- `EncodingFormat` enum

#### Tests
- Added 19 new tests for filters, delay, ring buffers, and encoder

## [0.1.0] - 2026-01-23

### Added

#### Build System
- Migrated from `setup.py` to modern Python packaging with `scikit-build-core` and CMake
- Added `uv` as the package manager with `pyproject.toml` configuration
- New `Makefile` with targets: `sync`, `build`, `test`, `wheel`, `sdist`, `clean`

#### Core Classes
- `Engine` - High-level audio engine for sound playback
  - Volume and gain control (linear and dB)
  - Time management (PCM frames and milliseconds)
  - Start/stop control
  - Spatial audio listener management (up to 4 listeners)
  - `play()` method for loading and playing sounds
  - `play_oneshot()` for fire-and-forget playback
  - Context manager support

- `Sound` - Individual sound objects with full parameter control
  - Playback control (start, stop, stop with fade)
  - Volume, pan, and pitch adjustment
  - Looping control
  - Seeking and position queries (frames and seconds)
  - Fading support
  - Scheduled playback (start/stop times)
  - 3D spatialization (position, direction, velocity)
  - Distance attenuation (model, rolloff, min/max distance)
  - Doppler effect control
  - Directional cones
  - Context manager support

- `Decoder` - Audio file decoding to PCM
  - Support for multiple output formats
  - Seeking and cursor position
  - Length queries (frames and seconds)
  - Chunked and full-file reading
  - Context manager support

- `Waveform` - Procedural waveform generation
  - Sine, square, triangle, sawtooth waveforms
  - Amplitude and frequency control
  - Seeking support
  - PCM frame reading

- `Noise` - Procedural noise generation
  - White, pink, and brownian noise types
  - Amplitude control
  - Seed configuration
  - PCM frame reading

- `DeviceInfo` - Audio device information container

#### Enums
- `Format` - Audio sample formats (U8, S16, S24, S32, F32)
- `DeviceType` - Device types (PLAYBACK, CAPTURE, DUPLEX, LOOPBACK)
- `WaveformType` - Waveform types (SINE, SQUARE, TRIANGLE, SAWTOOTH)
- `NoiseType` - Noise types (WHITE, PINK, BROWNIAN)
- `AttenuationModel` - 3D audio attenuation models (NONE, INVERSE, LINEAR, EXPONENTIAL)

#### Exceptions
- `MinimaError` - Base exception class
- `DeviceError` - Device-related errors
- `DecoderError` - Decoding errors
- `EngineError` - Engine errors
- `SoundError` - Sound playback errors

#### Utility Functions
- `get_version()` - Get miniaudio version string
- `get_version_numbers()` - Get version as (major, minor, revision) tuple
- `list_devices()` - Enumerate playback and capture devices
- `get_default_device()` - Get the default device of a given type

#### Sound Flags
- `SOUND_FLAG_STREAM` - Stream audio instead of loading fully
- `SOUND_FLAG_DECODE` - Decode audio upfront
- `SOUND_FLAG_ASYNC` - Load asynchronously
- `SOUND_FLAG_NO_PITCH` - Disable pitch shifting
- `SOUND_FLAG_NO_SPATIALIZATION` - Disable 3D audio

#### Tests
- Comprehensive test suite with 32 tests covering all new functionality
- Tests for version, enums, devices, engine, sound, decoder, waveform, noise, and exceptions

### Changed
- Reorganized source layout to `src/minima/` structure
- `list_devices()` now returns a dict with `DeviceInfo` objects instead of printing

### Deprecated
- `play_sine()`, `play_file()`, `engine_play_file()` - Legacy interactive demo functions retained for backwards compatibility; use `Engine` and `Sound` classes instead

### Removed
- `setup.py` - Replaced by `pyproject.toml` with scikit-build-core
- Root-level `minima.pyx` and `libminiaudio.pxd` - Moved to `src/minima/`
