"""Tests for minima audio library."""

import pytest
import minima

SOUNDFILE = 'tests/beat.wav'


class TestVersion:
    """Test version functions."""

    def test_get_version(self):
        """Test that miniaudio version is returned."""
        version = minima.get_version()
        assert version
        assert isinstance(version, str)
        assert '.' in version

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
        assert 'playback' in devices
        assert 'capture' in devices
        assert isinstance(devices['playback'], list)
        assert isinstance(devices['capture'], list)

    def test_device_info(self):
        """Test DeviceInfo objects."""
        devices = minima.list_devices()
        if devices['playback']:
            dev = devices['playback'][0]
            assert hasattr(dev, 'name')
            assert hasattr(dev, 'is_default')
            assert hasattr(dev, 'device_type')
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
        with minima.Engine() as engine:
            with minima.Sound(engine, SOUNDFILE) as sound:
                assert sound.path == SOUNDFILE

    def test_sound_properties(self):
        """Test sound property access."""
        with minima.Engine() as engine:
            with minima.Sound(engine, SOUNDFILE) as sound:
                # Test readable properties
                assert sound.volume >= 0
                assert sound.pan >= -1 and sound.pan <= 1
                assert sound.pitch > 0
                assert not sound.looping
                assert sound.length > 0

    def test_sound_volume(self):
        """Test sound volume control."""
        with minima.Engine() as engine:
            with minima.Sound(engine, SOUNDFILE) as sound:
                sound.volume = 0.5
                assert abs(sound.volume - 0.5) < 0.01

    def test_sound_looping(self):
        """Test sound looping control."""
        with minima.Engine() as engine:
            with minima.Sound(engine, SOUNDFILE) as sound:
                assert not sound.looping
                sound.looping = True
                assert sound.looping

    def test_sound_invalid_file(self):
        """Test loading invalid file raises error."""
        with minima.Engine() as engine:
            with pytest.raises(minima.SoundError):
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
            waveform_type=minima.WaveformType.SINE,
            amplitude=0.5,
            frequency=440.0
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
        for wtype in [minima.WaveformType.SINE, minima.WaveformType.SQUARE,
                      minima.WaveformType.TRIANGLE, minima.WaveformType.SAWTOOTH]:
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
        for ntype in [minima.NoiseType.WHITE, minima.NoiseType.PINK,
                      minima.NoiseType.BROWNIAN]:
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


if __name__ == '__main__':
    version = minima.get_version()
    print(f"minima {minima.__version__}: miniaudio {version}\n")

    # Run a quick smoke test
    print("Listing devices...")
    devices = minima.list_devices()
    for dev in devices['playback']:
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
