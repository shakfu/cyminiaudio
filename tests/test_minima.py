"""Tests for cyminiaudio audio library."""

import pytest

import cyminiaudio

SOUNDFILE = "tests/beat.wav"


class TestVersion:
    """Test version functions."""

    def test_get_version(self):
        """Test that miniaudio version is returned."""
        version = cyminiaudio.get_version()
        assert version
        assert isinstance(version, str)
        assert "." in version

    def test_get_version_numbers(self):
        """Test that version numbers are returned as tuple."""
        major, minor, revision = cyminiaudio.get_version_numbers()
        assert isinstance(major, int)
        assert isinstance(minor, int)
        assert isinstance(revision, int)
        assert major >= 0


class TestEnums:
    """Test enum definitions."""

    def test_format_enum(self):
        """Test Format enum values."""
        assert cyminiaudio.Format.U8 == 1
        assert cyminiaudio.Format.S16 == 2
        assert cyminiaudio.Format.F32 == 5

    def test_waveform_type_enum(self):
        """Test WaveformType enum values."""
        assert cyminiaudio.WaveformType.SINE == 0
        assert cyminiaudio.WaveformType.SQUARE == 1
        assert cyminiaudio.WaveformType.TRIANGLE == 2
        assert cyminiaudio.WaveformType.SAWTOOTH == 3

    def test_noise_type_enum(self):
        """Test NoiseType enum values."""
        assert cyminiaudio.NoiseType.WHITE == 0
        assert cyminiaudio.NoiseType.PINK == 1
        assert cyminiaudio.NoiseType.BROWNIAN == 2


class TestDevices:
    """Test device enumeration."""

    def test_list_devices(self):
        """Test listing available devices."""
        devices = cyminiaudio.list_devices()
        assert "playback" in devices
        assert "capture" in devices
        assert isinstance(devices["playback"], list)
        assert isinstance(devices["capture"], list)

    def test_device_info(self):
        """Test DeviceInfo objects."""
        devices = cyminiaudio.list_devices()
        if devices["playback"]:
            dev = devices["playback"][0]
            assert hasattr(dev, "name")
            assert hasattr(dev, "is_default")
            assert hasattr(dev, "device_type")
            assert isinstance(dev.name, str)

    def test_get_default_device(self):
        """Test getting default device."""
        device = cyminiaudio.get_default_device()
        # May be None if no devices available
        if device is not None:
            assert isinstance(device, cyminiaudio.DeviceInfo)


class TestEngine:
    """Test Engine class."""

    def test_engine_init(self):
        """Test engine initialization."""
        engine = cyminiaudio.Engine()
        assert engine.sample_rate > 0
        assert engine.channels > 0
        engine.close()

    def test_engine_context_manager(self):
        """Test engine as context manager."""
        with cyminiaudio.Engine() as engine:
            assert engine.sample_rate > 0

    def test_engine_volume(self):
        """Test engine volume control."""
        with cyminiaudio.Engine() as engine:
            original = engine.volume
            engine.volume = 0.5
            assert abs(engine.volume - 0.5) < 0.01
            engine.volume = original

    def test_engine_listener_count(self):
        """Test engine listener count."""
        with cyminiaudio.Engine(listener_count=2) as engine:
            assert engine.listener_count == 2


class TestSound:
    """Test Sound class."""

    def test_sound_load(self):
        """Test loading a sound file."""
        with cyminiaudio.Engine() as engine:
            sound = cyminiaudio.Sound(engine, SOUNDFILE)
            assert sound.path == SOUNDFILE
            assert not sound.is_playing
            sound.close()

    def test_sound_context_manager(self):
        """Test sound as context manager."""
        with cyminiaudio.Engine() as engine, cyminiaudio.Sound(engine, SOUNDFILE) as sound:
            assert sound.path == SOUNDFILE

    def test_sound_properties(self):
        """Test sound property access."""
        with cyminiaudio.Engine() as engine, cyminiaudio.Sound(engine, SOUNDFILE) as sound:
            # Test readable properties
            assert sound.volume >= 0
            assert sound.pan >= -1 and sound.pan <= 1
            assert sound.pitch > 0
            assert not sound.looping
            assert sound.length > 0

    def test_sound_volume(self):
        """Test sound volume control."""
        with cyminiaudio.Engine() as engine, cyminiaudio.Sound(engine, SOUNDFILE) as sound:
            sound.volume = 0.5
            assert abs(sound.volume - 0.5) < 0.01

    def test_sound_looping(self):
        """Test sound looping control."""
        with cyminiaudio.Engine() as engine, cyminiaudio.Sound(engine, SOUNDFILE) as sound:
            assert not sound.looping
            sound.looping = True
            assert sound.looping

    def test_sound_invalid_file(self):
        """Test loading invalid file raises error."""
        with cyminiaudio.Engine() as engine, pytest.raises(cyminiaudio.SoundError):
            cyminiaudio.Sound(engine, "nonexistent.wav")


class TestDecoder:
    """Test Decoder class."""

    def test_decoder_init(self):
        """Test decoder initialization."""
        decoder = cyminiaudio.Decoder(SOUNDFILE)
        assert decoder.path == SOUNDFILE
        assert decoder.channels > 0
        assert decoder.sample_rate > 0
        decoder.close()

    def test_decoder_context_manager(self):
        """Test decoder as context manager."""
        with cyminiaudio.Decoder(SOUNDFILE) as decoder:
            assert decoder.channels > 0

    def test_decoder_read(self):
        """Test reading frames from decoder."""
        with cyminiaudio.Decoder(SOUNDFILE) as decoder:
            data = decoder.read(1024)
            assert len(data) > 0
            assert isinstance(data, bytes)

    def test_decoder_seek(self):
        """Test seeking in decoder."""
        with cyminiaudio.Decoder(SOUNDFILE) as decoder:
            decoder.seek(0)
            assert decoder.cursor == 0

    def test_decoder_length(self):
        """Test decoder length properties."""
        with cyminiaudio.Decoder(SOUNDFILE) as decoder:
            assert decoder.length > 0
            assert decoder.length_seconds > 0

    def test_decoder_invalid_file(self):
        """Test decoding invalid file raises error."""
        with pytest.raises(cyminiaudio.DecoderError):
            cyminiaudio.Decoder("nonexistent.wav")


class TestWaveform:
    """Test Waveform class."""

    def test_waveform_init(self):
        """Test waveform initialization."""
        waveform = cyminiaudio.Waveform(
            waveform_type=cyminiaudio.WaveformType.SINE, amplitude=0.5, frequency=440.0
        )
        assert waveform.amplitude == 0.5
        assert waveform.frequency == 440.0

    def test_waveform_read(self):
        """Test reading frames from waveform."""
        waveform = cyminiaudio.Waveform()
        data = waveform.read(1024)
        assert len(data) > 0
        assert isinstance(data, bytes)
        # 1024 frames * 2 channels * 4 bytes per float = 8192 bytes
        assert len(data) == 1024 * 2 * 4

    def test_waveform_types(self):
        """Test different waveform types."""
        for wtype in [
            cyminiaudio.WaveformType.SINE,
            cyminiaudio.WaveformType.SQUARE,
            cyminiaudio.WaveformType.TRIANGLE,
            cyminiaudio.WaveformType.SAWTOOTH,
        ]:
            waveform = cyminiaudio.Waveform(waveform_type=wtype)
            assert waveform.waveform_type == wtype

    def test_waveform_set_properties(self):
        """Test setting waveform properties."""
        waveform = cyminiaudio.Waveform()
        waveform.amplitude = 0.3
        waveform.frequency = 880.0
        waveform.waveform_type = cyminiaudio.WaveformType.SQUARE
        assert waveform.waveform_type == cyminiaudio.WaveformType.SQUARE


class TestNoise:
    """Test Noise class."""

    def test_noise_init(self):
        """Test noise initialization."""
        noise = cyminiaudio.Noise(noise_type=cyminiaudio.NoiseType.WHITE, amplitude=0.5)
        assert noise.amplitude == 0.5

    def test_noise_read(self):
        """Test reading frames from noise generator."""
        noise = cyminiaudio.Noise()
        data = noise.read(1024)
        assert len(data) > 0
        assert isinstance(data, bytes)

    def test_noise_types(self):
        """Test different noise types."""
        for ntype in [
            cyminiaudio.NoiseType.WHITE,
            cyminiaudio.NoiseType.PINK,
            cyminiaudio.NoiseType.BROWNIAN,
        ]:
            noise = cyminiaudio.Noise(noise_type=ntype)
            assert noise.noise_type == ntype


class TestExceptions:
    """Test exception classes."""

    def test_exception_hierarchy(self):
        """Test exception class hierarchy."""
        assert issubclass(cyminiaudio.DeviceError, cyminiaudio.MinimaError)
        assert issubclass(cyminiaudio.DecoderError, cyminiaudio.MinimaError)
        assert issubclass(cyminiaudio.EngineError, cyminiaudio.MinimaError)
        assert issubclass(cyminiaudio.SoundError, cyminiaudio.MinimaError)


class TestFilters:
    """Test audio filter classes."""

    def test_lowpass_filter(self):
        """Test low-pass filter."""
        lpf = cyminiaudio.LowPassFilter(cutoff=1000.0, order=2)
        # Generate test data (1024 frames, 2 channels, float32)
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        # Process through filter
        output = lpf.process(data)
        assert len(output) == len(data)

    def test_highpass_filter(self):
        """Test high-pass filter."""
        hpf = cyminiaudio.HighPassFilter(cutoff=200.0, order=2)
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = hpf.process(data)
        assert len(output) == len(data)

    def test_bandpass_filter(self):
        """Test band-pass filter."""
        bpf = cyminiaudio.BandPassFilter(cutoff=1000.0, order=2)
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = bpf.process(data)
        assert len(output) == len(data)

    def test_notch_filter(self):
        """Test notch filter."""
        notch = cyminiaudio.NotchFilter(frequency=60.0, q=10.0)
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = notch.process(data)
        assert len(output) == len(data)

    def test_peak_filter(self):
        """Test peak EQ filter."""
        peak = cyminiaudio.PeakFilter(frequency=1000.0, gain_db=6.0, q=1.0)
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = peak.process(data)
        assert len(output) == len(data)

    def test_lowshelf_filter(self):
        """Test low shelf filter."""
        loshelf = cyminiaudio.LowShelfFilter(frequency=200.0, gain_db=3.0)
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = loshelf.process(data)
        assert len(output) == len(data)

    def test_highshelf_filter(self):
        """Test high shelf filter."""
        hishelf = cyminiaudio.HighShelfFilter(frequency=8000.0, gain_db=-3.0)
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = hishelf.process(data)
        assert len(output) == len(data)

    def test_filter_reinit(self):
        """Test reinitializing a filter with new cutoff."""
        lpf = cyminiaudio.LowPassFilter(cutoff=1000.0, order=2)
        lpf.reinit(cutoff=2000.0, order=2)  # Order must match original
        # Should not raise


class TestDelay:
    """Test delay effect."""

    def test_delay_init(self):
        """Test delay initialization."""
        delay = cyminiaudio.Delay(delay_ms=250.0, wet=0.5, decay=0.3)
        assert delay.wet == 0.5
        assert abs(delay.decay - 0.3) < 0.01

    def test_delay_process(self):
        """Test delay processing."""
        delay = cyminiaudio.Delay(delay_ms=100.0)
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = delay.process(data)
        assert len(output) == len(data)

    def test_delay_properties(self):
        """Test delay property setters."""
        delay = cyminiaudio.Delay()
        delay.wet = 0.7
        delay.dry = 0.8
        delay.decay = 0.4
        assert abs(delay.wet - 0.7) < 0.01
        assert abs(delay.dry - 0.8) < 0.01
        assert abs(delay.decay - 0.4) < 0.01


class TestRingBuffers:
    """Test ring buffer classes."""

    def test_ring_buffer_init(self):
        """Test ring buffer initialization."""
        rb = cyminiaudio.RingBuffer(buffer_size=4096)
        assert rb.available_read == 0
        assert rb.available_write > 0

    def test_ring_buffer_write_read(self):
        """Test ring buffer write and read."""
        rb = cyminiaudio.RingBuffer(buffer_size=4096)
        data = b"Hello, World!"
        written = rb.write(data)
        assert written == len(data)
        assert rb.available_read == len(data)

        output = rb.read(len(data))
        assert output == data

    def test_ring_buffer_reset(self):
        """Test ring buffer reset."""
        rb = cyminiaudio.RingBuffer(buffer_size=4096)
        rb.write(b"test data")
        rb.reset()
        assert rb.available_read == 0

    def test_pcm_ring_buffer_init(self):
        """Test PCM ring buffer initialization."""
        rb = cyminiaudio.PCMRingBuffer(frame_capacity=1024, channels=2)
        assert rb.available_read == 0
        assert rb.available_write > 0

    def test_pcm_ring_buffer_write_read(self):
        """Test PCM ring buffer write and read."""
        rb = cyminiaudio.PCMRingBuffer(frame_capacity=1024, channels=2)
        waveform = cyminiaudio.Waveform()
        data = waveform.read(256)

        frames_written = rb.write_frames(data)
        assert frames_written == 256

        output = rb.read_frames(256)
        assert len(output) == len(data)


class TestEncoder:
    """Test encoder class."""

    def test_encoder_init(self):
        """Test encoder initialization."""
        import os
        import tempfile

        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
            path = f.name

        try:
            encoder = cyminiaudio.Encoder(path, channels=2, sample_rate=48000)
            assert encoder.path == path
            encoder.close()
            assert os.path.exists(path)
        finally:
            if os.path.exists(path):
                os.unlink(path)

    def test_encoder_write(self):
        """Test encoder writing."""
        import os
        import tempfile

        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
            path = f.name

        try:
            with cyminiaudio.Encoder(path) as encoder:
                waveform = cyminiaudio.Waveform(frequency=440.0)
                data = waveform.read(1024)
                frames_written = encoder.write(data)
                assert frames_written == 1024

            # Verify file was written
            assert os.path.exists(path)
            assert os.path.getsize(path) > 0
        finally:
            if os.path.exists(path):
                os.unlink(path)

    def test_encoder_context_manager(self):
        """Test encoder as context manager."""
        import os
        import tempfile

        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
            path = f.name

        try:
            with cyminiaudio.Encoder(path) as encoder:
                waveform = cyminiaudio.Waveform()
                encoder.write(waveform.read(512))
            # File should be closed and valid
            assert os.path.exists(path)
        finally:
            if os.path.exists(path):
                os.unlink(path)


class TestNodeGraph:
    """Test node graph classes."""

    def test_node_graph_init(self):
        """Test node graph initialization."""
        graph = cyminiaudio.NodeGraph(channels=2)
        assert graph.channels == 2
        graph.close()

    def test_node_graph_context_manager(self):
        """Test node graph as context manager."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            assert graph.channels == 2

    def test_node_graph_time(self):
        """Test node graph time property."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            assert graph.time == 0
            graph.time = 1000
            assert graph.time == 1000

    def test_node_graph_read(self):
        """Test reading from node graph."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            # Read some frames (will be silence without connected sources)
            data = graph.read(1024)
            assert isinstance(data, bytes)

    def test_splitter_node_init(self):
        """Test splitter node initialization."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            splitter = cyminiaudio.SplitterNode(graph, channels=2, output_bus_count=2)
            assert splitter.state == cyminiaudio.NodeState.STARTED

    def test_splitter_node_volume(self):
        """Test splitter node volume control."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            splitter = cyminiaudio.SplitterNode(graph, channels=2, output_bus_count=2)
            splitter.set_output_volume(0, 0.5)
            assert abs(splitter.get_output_volume(0) - 0.5) < 0.01

    def test_lpf_node_init(self):
        """Test LPF node initialization."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            lpf = cyminiaudio.LPFNode(graph, cutoff=1000.0, order=2)
            assert lpf.state == cyminiaudio.NodeState.STARTED

    def test_hpf_node_init(self):
        """Test HPF node initialization."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            hpf = cyminiaudio.HPFNode(graph, cutoff=200.0, order=2)
            assert hpf.state == cyminiaudio.NodeState.STARTED

    def test_bpf_node_init(self):
        """Test BPF node initialization."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            bpf = cyminiaudio.BPFNode(graph, cutoff=1000.0, order=2)
            assert bpf.state == cyminiaudio.NodeState.STARTED

    def test_delay_node_init(self):
        """Test delay node initialization."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            delay = cyminiaudio.DelayNode(graph, delay_ms=250.0, decay=0.5)
            assert delay.state == cyminiaudio.NodeState.STARTED

    def test_delay_node_properties(self):
        """Test delay node property setters."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            delay = cyminiaudio.DelayNode(graph, delay_ms=250.0)
            delay.wet = 0.7
            delay.dry = 0.8
            delay.decay = 0.4
            assert abs(delay.wet - 0.7) < 0.01
            assert abs(delay.dry - 0.8) < 0.01
            assert abs(delay.decay - 0.4) < 0.01


class TestResourceManager:
    """Test resource manager classes."""

    def test_resource_manager_init(self):
        """Test resource manager initialization."""
        rm = cyminiaudio.ResourceManager()
        rm.close()

    def test_resource_manager_context_manager(self):
        """Test resource manager as context manager."""
        with cyminiaudio.ResourceManager():
            pass

    def test_resource_manager_load(self):
        """Test loading audio through resource manager."""
        with cyminiaudio.ResourceManager() as rm:
            source = rm.load(SOUNDFILE)
            assert source.path == SOUNDFILE
            assert source.length > 0
            source.close()

    def test_resource_data_source_read(self):
        """Test reading from resource data source."""
        with cyminiaudio.ResourceManager() as rm, rm.load(SOUNDFILE) as source:
            data = source.read(1024)
            assert len(data) > 0
            assert isinstance(data, bytes)

    def test_resource_data_source_seek(self):
        """Test seeking in resource data source."""
        with cyminiaudio.ResourceManager() as rm, rm.load(SOUNDFILE) as source:
            source.seek(0)
            assert source.cursor == 0

    def test_resource_data_source_looping(self):
        """Test looping property of resource data source."""
        with cyminiaudio.ResourceManager() as rm, rm.load(SOUNDFILE) as source:
            assert not source.is_looping
            source.is_looping = True
            assert source.is_looping


class TestDataConversion:
    """Test data conversion classes."""

    def test_linear_resampler_init(self):
        """Test linear resampler initialization."""
        resampler = cyminiaudio.LinearResampler(sample_rate_in=44100, sample_rate_out=48000)
        assert resampler.input_latency >= 0
        assert resampler.output_latency >= 0

    def test_linear_resampler_process(self):
        """Test linear resampler processing."""
        resampler = cyminiaudio.LinearResampler(sample_rate_in=44100, sample_rate_out=48000)
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = resampler.process(data)
        assert len(output) > 0
        assert isinstance(output, bytes)

    def test_channel_converter_init(self):
        """Test channel converter initialization."""
        converter = cyminiaudio.ChannelConverter(channels_in=1, channels_out=2)
        assert converter.channels_in == 1
        assert converter.channels_out == 2

    def test_channel_converter_mono_to_stereo(self):
        """Test converting mono to stereo."""
        converter = cyminiaudio.ChannelConverter(channels_in=1, channels_out=2)
        # Create mono waveform data
        waveform = cyminiaudio.Waveform(channels=1, frequency=440.0)
        mono_data = waveform.read(1024)
        stereo_data = converter.process(mono_data)
        # Stereo should be twice the size (2 channels vs 1)
        assert len(stereo_data) == len(mono_data) * 2

    def test_data_converter_init(self):
        """Test data converter initialization."""
        converter = cyminiaudio.DataConverter(
            format_in=cyminiaudio.Format.F32,
            format_out=cyminiaudio.Format.F32,
            channels_in=2,
            channels_out=2,
            sample_rate_in=44100,
            sample_rate_out=48000,
        )
        assert converter is not None

    def test_data_converter_process(self):
        """Test data converter processing."""
        converter = cyminiaudio.DataConverter(sample_rate_in=44100, sample_rate_out=48000)
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = converter.process(data)
        assert len(output) > 0


class TestVolumePanning:
    """Test volume and panning classes."""

    def test_panner_init(self):
        """Test panner initialization."""
        panner = cyminiaudio.Panner()
        assert panner.pan == 0.0

    def test_panner_process(self):
        """Test panner processing."""
        panner = cyminiaudio.Panner()
        panner.pan = -0.5
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = panner.process(data)
        assert len(output) == len(data)

    def test_panner_pan_property(self):
        """Test panner pan property."""
        panner = cyminiaudio.Panner()
        panner.pan = 0.75
        assert abs(panner.pan - 0.75) < 0.01

    def test_fader_init(self):
        """Test fader initialization."""
        fader = cyminiaudio.Fader()
        assert fader.current_volume >= 0

    def test_fader_set_fade(self):
        """Test fader fade setting."""
        fader = cyminiaudio.Fader()
        fader.set_fade(0.0, 1.0, 48000)
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = fader.process(data)
        assert len(output) == len(data)

    def test_gainer_init(self):
        """Test gainer initialization."""
        gainer = cyminiaudio.Gainer(channels=2)
        assert gainer is not None

    def test_gainer_process(self):
        """Test gainer processing."""
        gainer = cyminiaudio.Gainer(channels=2)
        gainer.set_gain(0.5)
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = gainer.process(data)
        assert len(output) == len(data)


class TestSpatialization:
    """Test 3D audio spatialization classes."""

    def test_spatializer_listener_init(self):
        """Test spatializer listener initialization."""
        listener = cyminiaudio.SpatializerListener(channels_out=2)
        pos = listener.get_position()
        assert len(pos) == 3

    def test_spatializer_listener_position(self):
        """Test setting listener position."""
        listener = cyminiaudio.SpatializerListener(channels_out=2)
        listener.set_position(1.0, 2.0, 3.0)
        pos = listener.get_position()
        assert abs(pos[0] - 1.0) < 0.01
        assert abs(pos[1] - 2.0) < 0.01
        assert abs(pos[2] - 3.0) < 0.01

    def test_spatializer_init(self):
        """Test spatializer initialization."""
        spatializer = cyminiaudio.Spatializer(channels_in=1, channels_out=2)
        pos = spatializer.get_position()
        assert len(pos) == 3

    def test_spatializer_process(self):
        """Test spatializer processing."""
        listener = cyminiaudio.SpatializerListener(channels_out=2)
        spatializer = cyminiaudio.Spatializer(channels_in=1, channels_out=2)
        spatializer.set_position(5.0, 0.0, 0.0)
        waveform = cyminiaudio.Waveform(channels=1, frequency=440.0)
        mono_data = waveform.read(1024)
        output = spatializer.process(listener, mono_data)
        # Output should be stereo (2 channels)
        assert len(output) == len(mono_data) * 2

    def test_spatializer_properties(self):
        """Test spatializer properties."""
        spatializer = cyminiaudio.Spatializer(channels_in=1, channels_out=2)
        spatializer.min_distance = 0.5
        spatializer.max_distance = 50.0
        spatializer.rolloff = 1.5
        assert abs(spatializer.min_distance - 0.5) < 0.01
        assert abs(spatializer.max_distance - 50.0) < 0.01
        assert abs(spatializer.rolloff - 1.5) < 0.01


class TestAudioBuffer:
    """Test audio buffer class."""

    def test_audio_buffer_init(self):
        """Test audio buffer initialization."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        buffer = cyminiaudio.AudioBuffer(data, channels=2)
        assert buffer.length == 1024
        assert buffer.cursor == 0

    def test_audio_buffer_read(self):
        """Test reading from audio buffer."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        buffer = cyminiaudio.AudioBuffer(data, channels=2)
        output = buffer.read(512)
        assert len(output) > 0
        assert buffer.cursor == 512

    def test_audio_buffer_seek(self):
        """Test seeking in audio buffer."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        buffer = cyminiaudio.AudioBuffer(data, channels=2)
        buffer.read(512)
        buffer.seek(0)
        assert buffer.cursor == 0

    def test_audio_buffer_at_end(self):
        """Test audio buffer at_end property."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(256)
        buffer = cyminiaudio.AudioBuffer(data, channels=2)
        assert not buffer.at_end
        buffer.read(256)
        assert buffer.at_end


class TestAudioBufferRef:
    """Test audio buffer reference class."""

    def test_audio_buffer_ref_init(self):
        """Test audio buffer ref initialization."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        ref = cyminiaudio.AudioBufferRef(data, channels=2)
        assert ref.length == 1024
        assert ref.cursor == 0

    def test_audio_buffer_ref_read(self):
        """Test reading from audio buffer ref."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        ref = cyminiaudio.AudioBufferRef(data, channels=2)
        output = ref.read(512)
        assert len(output) > 0
        assert ref.cursor == 512

    def test_audio_buffer_ref_set_data(self):
        """Test setting new data on buffer ref."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data1 = waveform.read(512)
        data2 = waveform.read(1024)
        ref = cyminiaudio.AudioBufferRef(data1, channels=2)
        assert ref.length == 512
        ref.set_data(data2)
        assert ref.length == 1024


class TestPagedAudioBuffer:
    """Test paged audio buffer class."""

    def test_paged_audio_buffer_init(self):
        """Test paged audio buffer initialization."""
        buffer = cyminiaudio.PagedAudioBuffer(channels=2)
        assert buffer.channels == 2
        assert buffer.length == 0
        buffer.close()

    def test_paged_audio_buffer_context_manager(self):
        """Test paged audio buffer as context manager."""
        with cyminiaudio.PagedAudioBuffer(channels=2) as buffer:
            assert buffer.channels == 2

    def test_paged_audio_buffer_append_and_read(self):
        """Test appending pages and reading."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        with cyminiaudio.PagedAudioBuffer(channels=2) as buffer:
            # Append some pages
            data1 = waveform.read(512)
            data2 = waveform.read(512)
            buffer.append_page(data1)
            buffer.append_page(data2)

            # Check length
            assert buffer.length == 1024

            # Read back
            output = buffer.read(256)
            assert len(output) > 0
            assert buffer.cursor == 256

    def test_paged_audio_buffer_seek(self):
        """Test seeking in paged buffer."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        with cyminiaudio.PagedAudioBuffer(channels=2) as buffer:
            data = waveform.read(1024)
            buffer.append_page(data)

            # Read some
            buffer.read(256)
            assert buffer.cursor == 256

            # Seek back to start
            buffer.seek(0)
            assert buffer.cursor == 0

    def test_paged_audio_buffer_multiple_pages(self):
        """Test multiple page operations."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        with cyminiaudio.PagedAudioBuffer(channels=2) as buffer:
            # Append multiple pages
            for _ in range(5):
                data = waveform.read(256)
                buffer.append_page(data)

            assert buffer.length == 1280  # 5 * 256


class TestLowLevelDevice:
    """Test low-level device access."""

    def test_device_init(self):
        """Test device initialization."""
        device = cyminiaudio.Device(device_type=cyminiaudio.DeviceType.PLAYBACK)
        assert device.device_type == cyminiaudio.DeviceType.PLAYBACK
        assert device.channels == 2
        device.close()

    def test_device_context_manager(self):
        """Test device as context manager."""
        with cyminiaudio.Device() as device:
            assert device.channels == 2

    def test_device_properties(self):
        """Test device properties."""
        with cyminiaudio.Device() as device:
            assert device.sample_rate > 0
            assert len(device.name) > 0

    def test_device_with_period_config(self):
        """Test device with period size configuration."""
        # Test with period size in milliseconds
        with cyminiaudio.Device(period_size_ms=20) as device:
            assert device.sample_rate > 0

    def test_device_duplex_mode(self):
        """Test duplex device initialization."""
        device = cyminiaudio.Device(device_type=cyminiaudio.DeviceType.DUPLEX)
        assert device.device_type == cyminiaudio.DeviceType.DUPLEX
        device.close()

    def test_context_init(self):
        """Test context initialization."""
        ctx = cyminiaudio.Context()
        ctx.close()

    def test_context_context_manager(self):
        """Test context as context manager."""
        with cyminiaudio.Context():
            pass


class TestDataSourceNode:
    """Test data source node."""

    def test_data_source_node_with_waveform(self):
        """Test data source node with waveform."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            waveform = cyminiaudio.Waveform(frequency=440.0)
            node = cyminiaudio.DataSourceNode(graph, waveform)
            assert node.state == cyminiaudio.NodeState.STARTED

    def test_data_source_node_looping(self):
        """Test data source node looping property."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            waveform = cyminiaudio.Waveform(frequency=440.0)
            node = cyminiaudio.DataSourceNode(graph, waveform)
            assert not node.is_looping
            node.is_looping = True
            assert node.is_looping


class TestPCMUtilities:
    """Test PCM utility functions."""

    def test_copy_pcm_frames(self):
        """Test copying PCM frames."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        copy = cyminiaudio.copy_pcm_frames(data, channels=2)
        assert len(copy) == len(data)
        assert copy == data

    def test_mix_pcm_frames_f32(self):
        """Test mixing PCM frames."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data1 = waveform.read(1024)
        data2 = waveform.read(1024)
        mixed = cyminiaudio.mix_pcm_frames_f32(data1, data2, volume=0.5)
        assert len(mixed) == len(data1)

    def test_mix_pcm_frames_different_volumes(self):
        """Test mixing with different volumes."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data1 = waveform.read(512)
        data2 = waveform.read(512)
        # Mix with zero volume should return original
        mixed = cyminiaudio.mix_pcm_frames_f32(data1, data2, volume=0.0)
        assert len(mixed) == len(data1)


class TestVolumeUtilities:
    """Test volume utility functions."""

    def test_volume_linear_to_db_unity(self):
        """Test linear to dB conversion at unity gain."""
        db = cyminiaudio.volume_linear_to_db(1.0)
        assert abs(db) < 0.001  # Should be ~0 dB

    def test_volume_linear_to_db_half(self):
        """Test linear to dB conversion at half amplitude."""
        db = cyminiaudio.volume_linear_to_db(0.5)
        assert -7.0 < db < -5.0  # Should be ~-6.02 dB

    def test_volume_db_to_linear_unity(self):
        """Test dB to linear conversion at unity gain."""
        linear = cyminiaudio.volume_db_to_linear(0.0)
        assert abs(linear - 1.0) < 0.001

    def test_volume_db_to_linear_half(self):
        """Test dB to linear conversion at -6dB."""
        linear = cyminiaudio.volume_db_to_linear(-6.0206)
        assert abs(linear - 0.5) < 0.01

    def test_volume_roundtrip(self):
        """Test linear -> dB -> linear roundtrip."""
        original = 0.75
        db = cyminiaudio.volume_linear_to_db(original)
        back = cyminiaudio.volume_db_to_linear(db)
        assert abs(back - original) < 0.001

    def test_apply_volume_factor_pcm_frames(self):
        """Test applying volume to PCM frames."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        # Apply 0.5 volume
        result = cyminiaudio.apply_volume_factor_pcm_frames(data, 0.5)
        assert len(result) == len(data)

    def test_apply_volume_factor_silence(self):
        """Test applying zero volume (silence)."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(512)
        result = cyminiaudio.apply_volume_factor_pcm_frames(data, 0.0)
        # All samples should be zero
        import struct

        samples = struct.unpack(f"{len(result) // 4}f", result)
        assert all(s == 0.0 for s in samples)

    def test_copy_and_apply_volume_factor_pcm_frames(self):
        """Test copying and applying volume."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        result = cyminiaudio.copy_and_apply_volume_factor_pcm_frames(data, 0.5)
        assert len(result) == len(data)

    def test_apply_volume_factor_pcm_frames_f32(self):
        """Test applying volume to f32 frames."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        result = cyminiaudio.apply_volume_factor_pcm_frames_f32(data, 2.0)
        assert len(result) == len(data)

    def test_copy_and_apply_volume_factor_pcm_frames_f32(self):
        """Test copying and applying volume to f32 frames."""
        waveform = cyminiaudio.Waveform(frequency=440.0)
        data = waveform.read(1024)
        result = cyminiaudio.copy_and_apply_volume_factor_pcm_frames_f32(data, 0.25)
        assert len(result) == len(data)


class TestAdditionalNodes:
    """Test additional node graph nodes."""

    def test_notch_node_init(self):
        """Test notch node initialization."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            notch = cyminiaudio.NotchNode(graph, frequency=60.0, q=10.0)
            assert notch.state == cyminiaudio.NodeState.STARTED

    def test_peak_node_init(self):
        """Test peak node initialization."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            peak = cyminiaudio.PeakNode(graph, frequency=1000.0, gain_db=6.0)
            assert peak.state == cyminiaudio.NodeState.STARTED

    def test_loshelf_node_init(self):
        """Test low shelf node initialization."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            loshelf = cyminiaudio.LoShelfNode(graph, frequency=200.0, gain_db=3.0)
            assert loshelf.state == cyminiaudio.NodeState.STARTED

    def test_hishelf_node_init(self):
        """Test high shelf node initialization."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            hishelf = cyminiaudio.HiShelfNode(graph, frequency=8000.0, gain_db=-3.0)
            assert hishelf.state == cyminiaudio.NodeState.STARTED

    def test_biquad_node_init(self):
        """Test biquad node initialization."""
        with cyminiaudio.NodeGraph(channels=2) as graph:
            # Pass-through coefficients
            biquad = cyminiaudio.BiquadNode(graph, b0=1.0, b1=0.0, b2=0.0, a0=1.0, a1=0.0, a2=0.0)
            assert biquad.state == cyminiaudio.NodeState.STARTED


# Interactive tests - require user input, skip in automated runs
@pytest.mark.skip(reason="Interactive: requires user input")
def test_play_sine():
    cyminiaudio.play_sine()


@pytest.mark.skip(reason="Interactive: requires user input")
def test_play_file():
    cyminiaudio.play_file(SOUNDFILE)


@pytest.mark.skip(reason="Interactive: requires user input")
def test_engine_play_file():
    cyminiaudio.engine_play_file(SOUNDFILE)


if __name__ == "__main__":
    version = cyminiaudio.get_version()
    print(f"cyminiaudio {cyminiaudio.__version__}: miniaudio {version}\n")

    # Run a quick smoke test
    print("Listing devices...")
    devices = cyminiaudio.list_devices()
    for dev in devices["playback"]:
        print(f"  {dev}")

    print("\nTesting engine...")
    with cyminiaudio.Engine() as engine:
        print(f"  Sample rate: {engine.sample_rate}")
        print(f"  Channels: {engine.channels}")

    print("\nTesting decoder...")
    with cyminiaudio.Decoder(SOUNDFILE) as decoder:
        print(f"  Duration: {decoder.length_seconds:.2f}s")
        print(f"  Channels: {decoder.channels}")
        print(f"  Sample rate: {decoder.sample_rate}")

    print("\nAll smoke tests passed!")
