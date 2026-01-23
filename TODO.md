# TODO: Additional miniaudio API Bindings

Features available in miniaudio 0.11.24 but not yet wrapped in cyminiaudio.

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

### Additional Node Graph Nodes
- [x] `ma_notch_node` - Notch filter as graph node (NotchNode)
- [x] `ma_peak_node` - Peak EQ as graph node (PeakNode)
- [x] `ma_loshelf_node` - Low shelf filter as graph node (LoShelfNode)
- [x] `ma_hishelf_node` - High shelf filter as graph node (HiShelfNode)
- [x] `ma_biquad_node` - Generic biquad filter node (BiquadNode)

## Remaining

### Buffers
- [ ] `ma_audio_buffer_ref` - Non-owning reference to audio buffer
- [ ] `ma_paged_audio_buffer` - Large audio buffer with paged memory

### Low-Level Device Access
- [ ] `ma_device` - Direct device access (bypassing Engine)
- [ ] `ma_context` - Device context for enumeration and configuration
- [ ] `ma_device_config` - Detailed device configuration options
- [ ] Duplex mode - Simultaneous playback and capture

### Additional Node Graph Nodes
- [ ] `ma_data_source_node` - Data source as graph node

### Miscellaneous
- [ ] `ma_copy_and_apply_volume_factor_*` - Optimized volume application
- [ ] `ma_mix_pcm_frames_*` - PCM frame mixing utilities
- [ ] `ma_slot_allocator` - Efficient slot-based allocation
- [ ] Custom decoding backends - Support for additional codecs
