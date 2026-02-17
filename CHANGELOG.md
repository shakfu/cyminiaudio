# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2]

### Added

#### Core
- `Engine.play_data_source()` - Play a data source (Waveform, Noise, Decoder, AudioBuffer, AudioBufferRef) directly through the engine without writing to a temp file
- `Sound` now accepts data sources in addition to file paths: `Sound(engine, waveform)` or `Sound(engine, "file.wav")`

#### CI/CD
- Re-enabled push/PR/workflow_dispatch triggers on build-wheels workflow
- Added test and lint job to build-wheels workflow (runs on Ubuntu and macOS)
- New `release.yml` workflow for tag-triggered PyPI publishing via trusted publishing

#### Tests
- Encoder round-trip test verifying sample-level data integrity
- 10 integration tests combining multiple components (waveform -> filter, encode -> decode -> filter, node graph pipelines, resampler -> channel converter, engine/sound lifecycle, play_data_source with Waveform/Decoder/Noise)
- 4 concurrency tests exercising GIL release with parallel threads (filters, decoders, waveforms, encode/decode)
- Total test count: 141 tests

#### Documentation
- Architecture diagram and layer overview in README
- Troubleshooting section in README (Linux ALSA, macOS permissions, CMake, device selection, latency, ABI mismatch)

#### Build
- `make coverage` target using pytest-cov

### Changed
- License changed from Public Domain to MIT
- Minimum Python version raised to 3.10 (was 3.9); updated ruff target-version, classifiers, cibuildwheel config, and Makefile release target accordingly
- Added Python 3.14 to cibuildwheel build matrix
- CMake minimum version raised to 3.17 (for WITH_SOABI support)

#### Error Handling
- Wrapped 55 previously unchecked `ma_result` return values with `_check_result()` across Engine, Sound, Waveform, Noise, Decoder, Encoder, filters, delay, ring buffers, data conversion, node graph, and resource manager
- Decoder.read() now correctly handles `MA_AT_END` as a non-error condition

#### Performance
- `Device.start()` and `Device.stop()` now release the GIL during C calls (added `nogil` declarations to `libminiaudio.pxd`)

#### Configuration
- mypy configured with `strict = true` in pyproject.toml (replaced individual flags)
- Added mypy per-module override to relax type annotations on test files
- ruff lint rules expanded: added isort (`I`), bugbear (`B`), comprehensions (`C4`), pyupgrade (`UP`), simplify (`SIM`)
- Fixed `[project.urls]` to point to correct repository
- Makefile `release` target now cleans first and uses a loop for Python versions

### Removed
- `play_sine()`, `play_file()`, `engine_play_file()` legacy interactive demo functions (use `Engine` and `Sound` classes instead)
- `DEVICE_CHANNELS` and `DEVICE_SAMPLE_RATE` module constants (only used by removed legacy functions)

## [0.1.1]

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

#### Node Graph
- `NodeGraph` - Audio processing graph container with channel configuration and time control
- `SplitterNode` - Splits audio to multiple output buses with per-bus volume control
- `LPFNode` - Low-pass filter node for the node graph
- `HPFNode` - High-pass filter node for the node graph
- `BPFNode` - Band-pass filter node for the node graph
- `DelayNode` - Delay effect node with wet/dry/decay control
- `NodeState` enum for node state management (STARTED, STOPPED)

#### Resource Manager
- `ResourceManager` - Manages async audio resource loading and caching
  - Configurable decoded format, channels, and sample rate
  - Job thread pool for async operations
  - File registration for preloading
- `ResourceDataSource` - Data source for audio loaded through ResourceManager
  - Read, seek, and cursor position
  - Length queries
  - Looping control
- Resource manager flags:
  - `RESOURCE_MANAGER_FLAG_NON_BLOCKING`
  - `RESOURCE_MANAGER_DATA_SOURCE_FLAG_STREAM`
  - `RESOURCE_MANAGER_DATA_SOURCE_FLAG_DECODE`
  - `RESOURCE_MANAGER_DATA_SOURCE_FLAG_ASYNC`
  - `RESOURCE_MANAGER_DATA_SOURCE_FLAG_WAIT_INIT`

#### Development Tooling
- Added `ruff` for linting and formatting
  - Configured with pycodestyle, Pyflakes, isort, flake8-bugbear, flake8-comprehensions, pyupgrade, flake8-simplify rules
- Added `mypy` for static type checking
- New Makefile targets:
  - `lint` - Check code with ruff
  - `format` - Format code with ruff
  - `typecheck` - Type check with mypy
  - `dist` - Build both wheel and sdist
  - `check` - Validate distributions with twine
  - `publish-test` - Upload to TestPyPI
  - `publish` - Upload to PyPI

#### Package Metadata
- Added full PyPI metadata to `pyproject.toml`:
  - README, license, authors, maintainers
  - Keywords for discoverability
  - Classifiers for Python versions, OS, topics
  - Project URLs (homepage, docs, issues, changelog)
  - Source distribution include/exclude rules

#### Tests
- 17 new tests for node graph (NodeGraph, SplitterNode, LPFNode, HPFNode, BPFNode, DelayNode)
- 6 new tests for resource manager (ResourceManager, ResourceDataSource)
- 8 new tests for filters
- 3 new tests for delay effect
- 5 new tests for ring buffers
- 3 new tests for encoder
- Total test count: 68 tests (65 passing, 3 interactive skipped)

### Changed

#### Performance: GIL Release for Audio Operations
- Added `nogil` blocks to release the Python GIL during I/O and DSP operations
- Enables other Python threads to run during audio processing (critical for real-time applications)
- Methods that now release the GIL:
  - `Waveform.seek()`, `Waveform.read()`
  - `Noise.read()`
  - `Decoder.seek()`, `Decoder.read()`
  - `Encoder.write()`
  - `NodeGraph.read()`
  - `ResourceDataSource.seek()`, `ResourceDataSource.read()`
  - All filter `process()` methods (LowPassFilter, HighPassFilter, BandPassFilter, NotchFilter, PeakFilter, LowShelfFilter, HighShelfFilter)
  - `Delay.process()`

## [0.1.0]

### Added

#### Build System
- Migrated from `setup.py` to modern Python packaging with `scikit-build-core` and CMake
- Added `uv` as the package manager with `pyproject.toml` configuration
- New `Makefile` with targets: `sync`, `build`, `test`, `wheel`, `sdist`, `clean`
- CMake-based build with platform-specific audio backend linking

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
- Initial test suite with 26 tests covering core functionality
- Tests for version, enums, devices, engine, sound, decoder, waveform, noise, and exceptions

### Changed
- Reorganized source layout to `src/cyminiaudio/` structure
- `list_devices()` now returns a dict with `DeviceInfo` objects instead of printing

### Deprecated
- `play_sine()`, `play_file()`, `engine_play_file()` - Legacy interactive demo functions retained for backwards compatibility; use `Engine` and `Sound` classes instead

### Removed
- `setup.py` - Replaced by `pyproject.toml` with scikit-build-core
- Root-level `cyminiaudio.pyx` and `libminiaudio.pxd` - Moved to `src/cyminiaudio/`
