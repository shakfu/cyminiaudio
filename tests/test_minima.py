"""Tests for minima audio library."""

import pytest

import minima

SOUNDFILE = "tests/beat.wav"


class TestVersion:
    """Test version functions."""

    def test_get_version(self):
        """Test that miniaudio version is returned."""
        version = minima.get_version()
        assert version
        assert isinstance(version, str)
        assert "." in version

    def test_get_version_numbers(self):
        """Test that version numbers are returned as tuple."""
        major, minor, revision = minima.get_version_numbers()
        assert isinstance(major, int)
        assert isinstance(minor, int)
        assert isinstance(revision, int)
        assert major >= 0


class TestEnums:
    """Test enum definitions."""

    def test_format_enum(self):
        """Test Format enum values."""
        assert minima.Format.U8 == 1
        assert minima.Format.S16 == 2
        assert minima.Format.F32 == 5

    def test_waveform_type_enum(self):
        """Test WaveformType enum values."""
        assert minima.WaveformType.SINE == 0
        assert minima.WaveformType.SQUARE == 1
        assert minima.WaveformType.TRIANGLE == 2
        assert minima.WaveformType.SAWTOOTH == 3

    def test_noise_type_enum(self):
        """Test NoiseType enum values."""
        assert minima.NoiseType.WHITE == 0
        assert minima.NoiseType.PINK == 1
        assert minima.NoiseType.BROWNIAN == 2


class TestDevices:
    """Test device enumeration."""

    def test_list_devices(self):
        """Test listing available devices."""
        devices = minima.list_devices()
        assert "playback" in devices
        assert "capture" in devices
        assert isinstance(devices["playback"], list)
        assert isinstance(devices["capture"], list)

    def test_device_info(self):
        """Test DeviceInfo objects."""
        devices = minima.list_devices()
        if devices["playback"]:
            dev = devices["playback"][0]
            assert hasattr(dev, "name")
            assert hasattr(dev, "is_default")
            assert hasattr(dev, "device_type")
            assert isinstance(dev.name, str)

    def test_get_default_device(self):
        """Test getting default device."""
        device = minima.get_default_device()
        # May be None if no devices available
        if device is not None:
            assert isinstance(device, minima.DeviceInfo)


class TestEngine:
    """Test Engine class."""

    def test_engine_init(self):
        """Test engine initialization."""
        engine = minima.Engine()
        assert engine.sample_rate > 0
        assert engine.channels > 0
        engine.close()

    def test_engine_context_manager(self):
        """Test engine as context manager."""
        with minima.Engine() as engine:
            assert engine.sample_rate > 0

    def test_engine_volume(self):
        """Test engine volume control."""
        with minima.Engine() as engine:
            original = engine.volume
            engine.volume = 0.5
            assert abs(engine.volume - 0.5) < 0.01
            engine.volume = original

    def test_engine_listener_count(self):
        """Test engine listener count."""
        with minima.Engine(listener_count=2) as engine:
            assert engine.listener_count == 2


class TestSound:
    """Test Sound class."""

    def test_sound_load(self):
        """Test loading a sound file."""
        with minima.Engine() as engine:
            sound = minima.Sound(engine, SOUNDFILE)
            assert sound.path == SOUNDFILE
            assert not sound.is_playing
            sound.close()

    def test_sound_context_manager(self):
        """Test sound as context manager."""
        with minima.Engine() as engine, minima.Sound(engine, SOUNDFILE) as sound:
            assert sound.path == SOUNDFILE

    def test_sound_properties(self):
        """Test sound property access."""
        with minima.Engine() as engine, minima.Sound(engine, SOUNDFILE) as sound:
            # Test readable properties
            assert sound.volume >= 0
            assert sound.pan >= -1 and sound.pan <= 1
            assert sound.pitch > 0
            assert not sound.looping
            assert sound.length > 0

    def test_sound_volume(self):
        """Test sound volume control."""
        with minima.Engine() as engine, minima.Sound(engine, SOUNDFILE) as sound:
            sound.volume = 0.5
            assert abs(sound.volume - 0.5) < 0.01

    def test_sound_looping(self):
        """Test sound looping control."""
        with minima.Engine() as engine, minima.Sound(engine, SOUNDFILE) as sound:
            assert not sound.looping
            sound.looping = True
            assert sound.looping

    def test_sound_invalid_file(self):
        """Test loading invalid file raises error."""
        with minima.Engine() as engine, pytest.raises(minima.SoundError):
            minima.Sound(engine, "nonexistent.wav")


class TestDecoder:
    """Test Decoder class."""

    def test_decoder_init(self):
        """Test decoder initialization."""
        decoder = minima.Decoder(SOUNDFILE)
        assert decoder.path == SOUNDFILE
        assert decoder.channels > 0
        assert decoder.sample_rate > 0
        decoder.close()

    def test_decoder_context_manager(self):
        """Test decoder as context manager."""
        with minima.Decoder(SOUNDFILE) as decoder:
            assert decoder.channels > 0

    def test_decoder_read(self):
        """Test reading frames from decoder."""
        with minima.Decoder(SOUNDFILE) as decoder:
            data = decoder.read(1024)
            assert len(data) > 0
            assert isinstance(data, bytes)

    def test_decoder_seek(self):
        """Test seeking in decoder."""
        with minima.Decoder(SOUNDFILE) as decoder:
            decoder.seek(0)
            assert decoder.cursor == 0

    def test_decoder_length(self):
        """Test decoder length properties."""
        with minima.Decoder(SOUNDFILE) as decoder:
            assert decoder.length > 0
            assert decoder.length_seconds > 0

    def test_decoder_invalid_file(self):
        """Test decoding invalid file raises error."""
        with pytest.raises(minima.DecoderError):
            minima.Decoder("nonexistent.wav")


class TestWaveform:
    """Test Waveform class."""

    def test_waveform_init(self):
        """Test waveform initialization."""
        waveform = minima.Waveform(
            waveform_type=minima.WaveformType.SINE, amplitude=0.5, frequency=440.0
        )
        assert waveform.amplitude == 0.5
        assert waveform.frequency == 440.0

    def test_waveform_read(self):
        """Test reading frames from waveform."""
        waveform = minima.Waveform()
        data = waveform.read(1024)
        assert len(data) > 0
        assert isinstance(data, bytes)
        # 1024 frames * 2 channels * 4 bytes per float = 8192 bytes
        assert len(data) == 1024 * 2 * 4

    def test_waveform_types(self):
        """Test different waveform types."""
        for wtype in [
            minima.WaveformType.SINE,
            minima.WaveformType.SQUARE,
            minima.WaveformType.TRIANGLE,
            minima.WaveformType.SAWTOOTH,
        ]:
            waveform = minima.Waveform(waveform_type=wtype)
            assert waveform.waveform_type == wtype

    def test_waveform_set_properties(self):
        """Test setting waveform properties."""
        waveform = minima.Waveform()
        waveform.amplitude = 0.3
        waveform.frequency = 880.0
        waveform.waveform_type = minima.WaveformType.SQUARE
        assert waveform.waveform_type == minima.WaveformType.SQUARE


class TestNoise:
    """Test Noise class."""

    def test_noise_init(self):
        """Test noise initialization."""
        noise = minima.Noise(noise_type=minima.NoiseType.WHITE, amplitude=0.5)
        assert noise.amplitude == 0.5

    def test_noise_read(self):
        """Test reading frames from noise generator."""
        noise = minima.Noise()
        data = noise.read(1024)
        assert len(data) > 0
        assert isinstance(data, bytes)

    def test_noise_types(self):
        """Test different noise types."""
        for ntype in [minima.NoiseType.WHITE, minima.NoiseType.PINK, minima.NoiseType.BROWNIAN]:
            noise = minima.Noise(noise_type=ntype)
            assert noise.noise_type == ntype


class TestExceptions:
    """Test exception classes."""

    def test_exception_hierarchy(self):
        """Test exception class hierarchy."""
        assert issubclass(minima.DeviceError, minima.MinimaError)
        assert issubclass(minima.DecoderError, minima.MinimaError)
        assert issubclass(minima.EngineError, minima.MinimaError)
        assert issubclass(minima.SoundError, minima.MinimaError)


class TestFilters:
    """Test audio filter classes."""

    def test_lowpass_filter(self):
        """Test low-pass filter."""
        lpf = minima.LowPassFilter(cutoff=1000.0, order=2)
        # Generate test data (1024 frames, 2 channels, float32)
        waveform = minima.Waveform(frequency=440.0)
        data = waveform.read(1024)
        # Process through filter
        output = lpf.process(data)
        assert len(output) == len(data)

    def test_highpass_filter(self):
        """Test high-pass filter."""
        hpf = minima.HighPassFilter(cutoff=200.0, order=2)
        waveform = minima.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = hpf.process(data)
        assert len(output) == len(data)

    def test_bandpass_filter(self):
        """Test band-pass filter."""
        bpf = minima.BandPassFilter(cutoff=1000.0, order=2)
        waveform = minima.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = bpf.process(data)
        assert len(output) == len(data)

    def test_notch_filter(self):
        """Test notch filter."""
        notch = minima.NotchFilter(frequency=60.0, q=10.0)
        waveform = minima.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = notch.process(data)
        assert len(output) == len(data)

    def test_peak_filter(self):
        """Test peak EQ filter."""
        peak = minima.PeakFilter(frequency=1000.0, gain_db=6.0, q=1.0)
        waveform = minima.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = peak.process(data)
        assert len(output) == len(data)

    def test_lowshelf_filter(self):
        """Test low shelf filter."""
        loshelf = minima.LowShelfFilter(frequency=200.0, gain_db=3.0)
        waveform = minima.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = loshelf.process(data)
        assert len(output) == len(data)

    def test_highshelf_filter(self):
        """Test high shelf filter."""
        hishelf = minima.HighShelfFilter(frequency=8000.0, gain_db=-3.0)
        waveform = minima.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = hishelf.process(data)
        assert len(output) == len(data)

    def test_filter_reinit(self):
        """Test reinitializing a filter with new cutoff."""
        lpf = minima.LowPassFilter(cutoff=1000.0, order=2)
        lpf.reinit(cutoff=2000.0, order=2)  # Order must match original
        # Should not raise


class TestDelay:
    """Test delay effect."""

    def test_delay_init(self):
        """Test delay initialization."""
        delay = minima.Delay(delay_ms=250.0, wet=0.5, decay=0.3)
        assert delay.wet == 0.5
        assert abs(delay.decay - 0.3) < 0.01

    def test_delay_process(self):
        """Test delay processing."""
        delay = minima.Delay(delay_ms=100.0)
        waveform = minima.Waveform(frequency=440.0)
        data = waveform.read(1024)
        output = delay.process(data)
        assert len(output) == len(data)

    def test_delay_properties(self):
        """Test delay property setters."""
        delay = minima.Delay()
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
        rb = minima.RingBuffer(buffer_size=4096)
        assert rb.available_read == 0
        assert rb.available_write > 0

    def test_ring_buffer_write_read(self):
        """Test ring buffer write and read."""
        rb = minima.RingBuffer(buffer_size=4096)
        data = b"Hello, World!"
        written = rb.write(data)
        assert written == len(data)
        assert rb.available_read == len(data)

        output = rb.read(len(data))
        assert output == data

    def test_ring_buffer_reset(self):
        """Test ring buffer reset."""
        rb = minima.RingBuffer(buffer_size=4096)
        rb.write(b"test data")
        rb.reset()
        assert rb.available_read == 0

    def test_pcm_ring_buffer_init(self):
        """Test PCM ring buffer initialization."""
        rb = minima.PCMRingBuffer(frame_capacity=1024, channels=2)
        assert rb.available_read == 0
        assert rb.available_write > 0

    def test_pcm_ring_buffer_write_read(self):
        """Test PCM ring buffer write and read."""
        rb = minima.PCMRingBuffer(frame_capacity=1024, channels=2)
        waveform = minima.Waveform()
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
            encoder = minima.Encoder(path, channels=2, sample_rate=48000)
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
            with minima.Encoder(path) as encoder:
                waveform = minima.Waveform(frequency=440.0)
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
            with minima.Encoder(path) as encoder:
                waveform = minima.Waveform()
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
        graph = minima.NodeGraph(channels=2)
        assert graph.channels == 2
        graph.close()

    def test_node_graph_context_manager(self):
        """Test node graph as context manager."""
        with minima.NodeGraph(channels=2) as graph:
            assert graph.channels == 2

    def test_node_graph_time(self):
        """Test node graph time property."""
        with minima.NodeGraph(channels=2) as graph:
            assert graph.time == 0
            graph.time = 1000
            assert graph.time == 1000

    def test_node_graph_read(self):
        """Test reading from node graph."""
        with minima.NodeGraph(channels=2) as graph:
            # Read some frames (will be silence without connected sources)
            data = graph.read(1024)
            assert isinstance(data, bytes)

    def test_splitter_node_init(self):
        """Test splitter node initialization."""
        with minima.NodeGraph(channels=2) as graph:
            splitter = minima.SplitterNode(graph, channels=2, output_bus_count=2)
            assert splitter.state == minima.NodeState.STARTED

    def test_splitter_node_volume(self):
        """Test splitter node volume control."""
        with minima.NodeGraph(channels=2) as graph:
            splitter = minima.SplitterNode(graph, channels=2, output_bus_count=2)
            splitter.set_output_volume(0, 0.5)
            assert abs(splitter.get_output_volume(0) - 0.5) < 0.01

    def test_lpf_node_init(self):
        """Test LPF node initialization."""
        with minima.NodeGraph(channels=2) as graph:
            lpf = minima.LPFNode(graph, cutoff=1000.0, order=2)
            assert lpf.state == minima.NodeState.STARTED

    def test_hpf_node_init(self):
        """Test HPF node initialization."""
        with minima.NodeGraph(channels=2) as graph:
            hpf = minima.HPFNode(graph, cutoff=200.0, order=2)
            assert hpf.state == minima.NodeState.STARTED

    def test_bpf_node_init(self):
        """Test BPF node initialization."""
        with minima.NodeGraph(channels=2) as graph:
            bpf = minima.BPFNode(graph, cutoff=1000.0, order=2)
            assert bpf.state == minima.NodeState.STARTED

    def test_delay_node_init(self):
        """Test delay node initialization."""
        with minima.NodeGraph(channels=2) as graph:
            delay = minima.DelayNode(graph, delay_ms=250.0, decay=0.5)
            assert delay.state == minima.NodeState.STARTED

    def test_delay_node_properties(self):
        """Test delay node property setters."""
        with minima.NodeGraph(channels=2) as graph:
            delay = minima.DelayNode(graph, delay_ms=250.0)
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
        rm = minima.ResourceManager()
        rm.close()

    def test_resource_manager_context_manager(self):
        """Test resource manager as context manager."""
        with minima.ResourceManager():
            pass

    def test_resource_manager_load(self):
        """Test loading audio through resource manager."""
        with minima.ResourceManager() as rm:
            source = rm.load(SOUNDFILE)
            assert source.path == SOUNDFILE
            assert source.length > 0
            source.close()

    def test_resource_data_source_read(self):
        """Test reading from resource data source."""
        with minima.ResourceManager() as rm, rm.load(SOUNDFILE) as source:
            data = source.read(1024)
            assert len(data) > 0
            assert isinstance(data, bytes)

    def test_resource_data_source_seek(self):
        """Test seeking in resource data source."""
        with minima.ResourceManager() as rm, rm.load(SOUNDFILE) as source:
            source.seek(0)
            assert source.cursor == 0

    def test_resource_data_source_looping(self):
        """Test looping property of resource data source."""
        with minima.ResourceManager() as rm, rm.load(SOUNDFILE) as source:
            assert not source.is_looping
            source.is_looping = True
            assert source.is_looping


# Interactive tests - require user input, skip in automated runs
@pytest.mark.skip(reason="Interactive: requires user input")
def test_play_sine():
    minima.play_sine()


@pytest.mark.skip(reason="Interactive: requires user input")
def test_play_file():
    minima.play_file(SOUNDFILE)


@pytest.mark.skip(reason="Interactive: requires user input")
def test_engine_play_file():
    minima.engine_play_file(SOUNDFILE)


if __name__ == "__main__":
    version = minima.get_version()
    print(f"minima {minima.__version__}: miniaudio {version}\n")

    # Run a quick smoke test
    print("Listing devices...")
    devices = minima.list_devices()
    for dev in devices["playback"]:
        print(f"  {dev}")

    print("\nTesting engine...")
    with minima.Engine() as engine:
        print(f"  Sample rate: {engine.sample_rate}")
        print(f"  Channels: {engine.channels}")

    print("\nTesting decoder...")
    with minima.Decoder(SOUNDFILE) as decoder:
        print(f"  Duration: {decoder.length_seconds:.2f}s")
        print(f"  Channels: {decoder.channels}")
        print(f"  Sample rate: {decoder.sample_rate}")

    print("\nAll smoke tests passed!")
