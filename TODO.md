# cyminiaudio API Coverage

Status of miniaudio 0.11.24 API bindings in cyminiaudio.

## Completed

### Data Conversion
- [x] `ma_linear_resampler` - Linear interpolation resampler (LinearResampler)
- [x] `ma_channel_converter` - Convert between different channel counts (ChannelConverter)
- [x] `ma_data_converter` - General-purpose format/rate/channel conversion (DataConverter)

### Volume Control
- [x] `ma_panner` - Stereo panning control (Panner)
- [x] `ma_fader` - Volume fading with linear interpolation over time (Fader)
- [x] `ma_gainer` - Gain control with smoothing to avoid clicks (Gainer)

### 3D Audio / Spatialization
- [x] `ma_spatializer` - Full 3D audio positioning with distance attenuation (Spatializer)
- [x] `ma_spatializer_listener` - Listener position/orientation for 3D audio (SpatializerListener)

### Buffers
- [x] `ma_audio_buffer` - In-memory audio buffer for procedural/dynamic audio (AudioBuffer)
- [x] `ma_audio_buffer_ref` - Non-owning reference to audio buffer (AudioBufferRef)
- [x] `ma_paged_audio_buffer` - Large audio buffer with paged memory (PagedAudioBuffer)

### Additional Node Graph Nodes
- [x] `ma_notch_node` - Notch filter as graph node (NotchNode)
- [x] `ma_peak_node` - Peak EQ as graph node (PeakNode)
- [x] `ma_loshelf_node` - Low shelf filter as graph node (LoShelfNode)
- [x] `ma_hishelf_node` - High shelf filter as graph node (HiShelfNode)
- [x] `ma_biquad_node` - Generic biquad filter node (BiquadNode)
- [x] `ma_data_source_node` - Data source as graph node (DataSourceNode)

### PCM Utilities
- [x] `ma_copy_pcm_frames` - Copy PCM frames between buffers (copy_pcm_frames)
- [x] `ma_mix_pcm_frames_f32` - Mix PCM frames with volume control (mix_pcm_frames_f32)

### Volume Utilities
- [x] `ma_volume_linear_to_db` - Convert linear volume to decibels (volume_linear_to_db)
- [x] `ma_volume_db_to_linear` - Convert decibels to linear volume (volume_db_to_linear)
- [x] `ma_apply_volume_factor_pcm_frames` - Apply volume in-place (apply_volume_factor_pcm_frames)
- [x] `ma_copy_and_apply_volume_factor_pcm_frames` - Copy and apply volume (copy_and_apply_volume_factor_pcm_frames)
- [x] `ma_apply_volume_factor_pcm_frames_f32` - Apply volume to f32 in-place (apply_volume_factor_pcm_frames_f32)
- [x] `ma_copy_and_apply_volume_factor_pcm_frames_f32` - Copy and apply volume to f32 (copy_and_apply_volume_factor_pcm_frames_f32)

### Low-Level Device Access
- [x] `ma_device` - Direct device access (bypassing Engine) (Device)
- [x] `ma_context` - Device context for enumeration and configuration (Context)
- [x] `ma_device_config` - Device configuration options: period_size_frames, period_size_ms, periods
- [x] Duplex mode - Supported via `Device(device_type=DeviceType.DUPLEX)`

## Not Planned

These items are internal utilities or require C callbacks that are difficult to expose in Python:

- `ma_slot_allocator` - Internal memory allocation utility (not useful for Python)
- Custom decoding backends - Requires C callbacks, complex to implement in Cython
- Specific device ID selection - Requires exposing ma_device_id which is backend-specific
