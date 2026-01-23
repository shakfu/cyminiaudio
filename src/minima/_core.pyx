# cython: language_level=3
# cython: embedsignature=True
"""
minima._core - Cython bindings for miniaudio

Provides Python bindings for the miniaudio audio library, including:
- Audio engine for high-level playback
- Sound objects with full parameter control
- Device enumeration
- Waveform and noise generation
- Audio decoding
"""

from enum import IntEnum
from typing import Optional, List, Tuple

cimport libminiaudio as lib
from libc.stdlib cimport malloc, free
from libc.string cimport memset, memcpy

# Build configuration
DEF MA_NO_DECODING = 0
DEF MA_NO_ENCODING = 1

DEF DEVICE_CHANNELS = 2
DEF DEVICE_SAMPLE_RATE = 48000


# -----------------------------------------------------------------------------
# Exceptions
# -----------------------------------------------------------------------------

class MinimaError(Exception):
    """Base exception for minima errors."""
    pass


class DeviceError(MinimaError):
    """Error related to audio device operations."""
    pass


class DecoderError(MinimaError):
    """Error related to audio decoding."""
    pass


class EngineError(MinimaError):
    """Error related to audio engine operations."""
    pass


class SoundError(MinimaError):
    """Error related to sound operations."""
    pass


cdef inline int _check_result(lib.ma_result result) except -1:
    """Check miniaudio result and raise appropriate exception."""
    if result == lib.MA_SUCCESS:
        return 0

    error_messages = {
        lib.MA_ERROR: "Generic error",
        lib.MA_INVALID_ARGS: "Invalid arguments",
        lib.MA_INVALID_OPERATION: "Invalid operation",
        lib.MA_OUT_OF_MEMORY: "Out of memory",
        lib.MA_OUT_OF_RANGE: "Out of range",
        lib.MA_ACCESS_DENIED: "Access denied",
        lib.MA_DOES_NOT_EXIST: "Does not exist",
        lib.MA_ALREADY_EXISTS: "Already exists",
        lib.MA_INVALID_FILE: "Invalid file",
        lib.MA_NO_BACKEND: "No backend available",
        lib.MA_NO_DEVICE: "No device available",
        lib.MA_DEVICE_NOT_INITIALIZED: "Device not initialized",
        lib.MA_DEVICE_NOT_STARTED: "Device not started",
        lib.MA_FORMAT_NOT_SUPPORTED: "Format not supported",
    }

    msg = error_messages.get(result, f"Unknown error (code {result})")
    raise MinimaError(msg)


# -----------------------------------------------------------------------------
# Enums
# -----------------------------------------------------------------------------

class Format(IntEnum):
    """Audio sample format."""
    UNKNOWN = lib.ma_format_unknown
    U8 = lib.ma_format_u8
    S16 = lib.ma_format_s16
    S24 = lib.ma_format_s24
    S32 = lib.ma_format_s32
    F32 = lib.ma_format_f32


class DeviceType(IntEnum):
    """Audio device type."""
    PLAYBACK = lib.ma_device_type_playback
    CAPTURE = lib.ma_device_type_capture
    DUPLEX = lib.ma_device_type_duplex
    LOOPBACK = lib.ma_device_type_loopback


class WaveformType(IntEnum):
    """Waveform generator type."""
    SINE = lib.ma_waveform_type_sine
    SQUARE = lib.ma_waveform_type_square
    TRIANGLE = lib.ma_waveform_type_triangle
    SAWTOOTH = lib.ma_waveform_type_sawtooth


class NoiseType(IntEnum):
    """Noise generator type."""
    WHITE = lib.ma_noise_type_white
    PINK = lib.ma_noise_type_pink
    BROWNIAN = lib.ma_noise_type_brownian


class AttenuationModel(IntEnum):
    """Sound attenuation model for 3D audio."""
    NONE = lib.ma_attenuation_model_none
    INVERSE = lib.ma_attenuation_model_inverse
    LINEAR = lib.ma_attenuation_model_linear
    EXPONENTIAL = lib.ma_attenuation_model_exponential


# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------

def get_version() -> str:
    """Get the miniaudio version string."""
    cdef const char* version = lib.ma_version_string()
    return version.decode('utf-8')


def get_version_numbers() -> Tuple[int, int, int]:
    """Get the miniaudio version as (major, minor, revision) tuple."""
    cdef lib.ma_uint32 major, minor, revision
    lib.ma_version(&major, &minor, &revision)
    return (major, minor, revision)


# -----------------------------------------------------------------------------
# Device Information
# -----------------------------------------------------------------------------

cdef class DeviceInfo:
    """Information about an audio device."""
    cdef public str name
    cdef public bint is_default
    cdef public int device_type

    def __init__(self, str name, bint is_default, int device_type):
        self.name = name
        self.is_default = is_default
        self.device_type = device_type

    def __repr__(self):
        type_str = "playback" if self.device_type == lib.ma_device_type_playback else "capture"
        default_str = " (default)" if self.is_default else ""
        return f"DeviceInfo({self.name!r}, {type_str}{default_str})"


def list_devices() -> dict:
    """
    List available audio devices.

    Returns:
        dict with 'playback' and 'capture' lists of DeviceInfo objects
    """
    cdef lib.ma_result result
    cdef lib.ma_context context
    cdef lib.ma_device_info* pPlaybackInfos
    cdef lib.ma_uint32 playbackCount
    cdef lib.ma_device_info* pCaptureInfos
    cdef lib.ma_uint32 captureCount
    cdef lib.ma_uint32 i

    result = lib.ma_context_init(NULL, 0, NULL, &context)
    if result != lib.MA_SUCCESS:
        raise DeviceError("Failed to initialize context")

    try:
        result = lib.ma_context_get_devices(
            &context,
            &pPlaybackInfos, &playbackCount,
            &pCaptureInfos, &captureCount
        )
        if result != lib.MA_SUCCESS:
            raise DeviceError("Failed to enumerate devices")

        playback_devices = []
        for i in range(playbackCount):
            name = pPlaybackInfos[i].name.decode('utf-8')
            is_default = bool(pPlaybackInfos[i].isDefault)
            playback_devices.append(DeviceInfo(name, is_default, lib.ma_device_type_playback))

        capture_devices = []
        for i in range(captureCount):
            name = pCaptureInfos[i].name.decode('utf-8')
            is_default = bool(pCaptureInfos[i].isDefault)
            capture_devices.append(DeviceInfo(name, is_default, lib.ma_device_type_capture))

        return {
            'playback': playback_devices,
            'capture': capture_devices
        }
    finally:
        lib.ma_context_uninit(&context)


def get_default_device(device_type: int = DeviceType.PLAYBACK) -> Optional[DeviceInfo]:
    """Get the default device of the specified type."""
    devices = list_devices()
    key = 'playback' if device_type == lib.ma_device_type_playback else 'capture'
    for dev in devices[key]:
        if dev.is_default:
            return dev
    return devices[key][0] if devices[key] else None


# -----------------------------------------------------------------------------
# Engine Class
# -----------------------------------------------------------------------------

cdef class Engine:
    """
    High-level audio engine for sound playback.

    The Engine provides a simple interface for playing sounds with automatic
    resource management, mixing, and optional spatial audio support.

    Example:
        engine = Engine()
        sound = engine.play("music.mp3")
        sound.volume = 0.5
    """
    cdef lib.ma_engine _engine
    cdef bint _initialized

    def __cinit__(self):
        self._initialized = False

    def __init__(self, int sample_rate=0, int channels=0, int listener_count=1):
        """
        Initialize the audio engine.

        Args:
            sample_rate: Sample rate (0 for default)
            channels: Number of channels (0 for default)
            listener_count: Number of listeners for spatial audio (1-4)
        """
        cdef lib.ma_engine_config config
        cdef lib.ma_result result

        config = lib.ma_engine_config_init()
        if sample_rate > 0:
            config.sampleRate = sample_rate
        if channels > 0:
            config.channels = channels
        config.listenerCount = min(max(listener_count, 1), 4)

        result = lib.ma_engine_init(&config, &self._engine)
        if result != lib.MA_SUCCESS:
            raise EngineError(f"Failed to initialize engine (error {result})")
        self._initialized = True

    def __dealloc__(self):
        if self._initialized:
            lib.ma_engine_uninit(&self._engine)
            self._initialized = False

    def close(self):
        """Close the engine and release resources."""
        if self._initialized:
            lib.ma_engine_uninit(&self._engine)
            self._initialized = False

    @property
    def sample_rate(self) -> int:
        """Get the engine's sample rate."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        return lib.ma_engine_get_sample_rate(&self._engine)

    @property
    def channels(self) -> int:
        """Get the number of output channels."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        return lib.ma_engine_get_channels(&self._engine)

    @property
    def time(self) -> int:
        """Get the current time in PCM frames."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        return lib.ma_engine_get_time_in_pcm_frames(&self._engine)

    @time.setter
    def time(self, lib.ma_uint64 value):
        """Set the current time in PCM frames."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        lib.ma_engine_set_time_in_pcm_frames(&self._engine, value)

    @property
    def time_ms(self) -> int:
        """Get the current time in milliseconds."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        return lib.ma_engine_get_time_in_milliseconds(&self._engine)

    @property
    def volume(self) -> float:
        """Get the master volume (0.0 to 1.0+)."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        return lib.ma_engine_get_volume(&self._engine)

    @volume.setter
    def volume(self, float value):
        """Set the master volume (0.0 to 1.0+)."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        lib.ma_engine_set_volume(&self._engine, value)

    @property
    def gain_db(self) -> float:
        """Get the master gain in decibels."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        return lib.ma_engine_get_gain_db(&self._engine)

    @gain_db.setter
    def gain_db(self, float value):
        """Set the master gain in decibels."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        lib.ma_engine_set_gain_db(&self._engine, value)

    @property
    def listener_count(self) -> int:
        """Get the number of listeners."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        return lib.ma_engine_get_listener_count(&self._engine)

    def start(self):
        """Start the engine if it was stopped."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        cdef lib.ma_result result = lib.ma_engine_start(&self._engine)
        _check_result(result)

    def stop(self):
        """Stop the engine."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        cdef lib.ma_result result = lib.ma_engine_stop(&self._engine)
        _check_result(result)

    def play(self, str path, bint looping=False, float volume=1.0) -> "Sound":
        """
        Load and play a sound file.

        Args:
            path: Path to the audio file
            looping: Whether to loop the sound
            volume: Initial volume (0.0 to 1.0+)

        Returns:
            Sound object for controlling playback
        """
        sound = Sound(self, path)
        sound.looping = looping
        sound.volume = volume
        sound.start()
        return sound

    def play_oneshot(self, str path):
        """
        Play a sound once without creating a Sound object.

        This is more efficient for short sounds that don't need control.

        Args:
            path: Path to the audio file
        """
        if not self._initialized:
            raise EngineError("Engine not initialized")
        cdef bytes path_bytes = path.encode('utf-8')
        cdef lib.ma_result result = lib.ma_engine_play_sound(&self._engine, path_bytes, NULL)
        _check_result(result)

    def set_listener_position(self, int index, float x, float y, float z):
        """Set the position of a listener for 3D audio."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        lib.ma_engine_listener_set_position(&self._engine, index, x, y, z)

    def set_listener_direction(self, int index, float x, float y, float z):
        """Set the direction a listener is facing."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        lib.ma_engine_listener_set_direction(&self._engine, index, x, y, z)

    def set_listener_velocity(self, int index, float x, float y, float z):
        """Set the velocity of a listener (for doppler effect)."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        lib.ma_engine_listener_set_velocity(&self._engine, index, x, y, z)

    def set_listener_world_up(self, int index, float x, float y, float z):
        """Set the world up vector for a listener."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        lib.ma_engine_listener_set_world_up(&self._engine, index, x, y, z)

    def set_listener_cone(self, int index, float inner_angle, float outer_angle, float outer_gain):
        """
        Set the listener's cone for directional hearing.

        Args:
            index: Listener index
            inner_angle: Inner cone angle in radians
            outer_angle: Outer cone angle in radians
            outer_gain: Gain applied outside the outer cone
        """
        if not self._initialized:
            raise EngineError("Engine not initialized")
        lib.ma_engine_listener_set_cone(&self._engine, index, inner_angle, outer_angle, outer_gain)

    def set_listener_enabled(self, int index, bint enabled):
        """Enable or disable a listener."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        lib.ma_engine_listener_set_enabled(&self._engine, index, enabled)

    def is_listener_enabled(self, int index) -> bool:
        """Check if a listener is enabled."""
        if not self._initialized:
            raise EngineError("Engine not initialized")
        return bool(lib.ma_engine_listener_is_enabled(&self._engine, index))

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
        return False


# -----------------------------------------------------------------------------
# Sound Class
# -----------------------------------------------------------------------------

# Sound flags
SOUND_FLAG_STREAM = lib.MA_SOUND_FLAG_STREAM
SOUND_FLAG_DECODE = lib.MA_SOUND_FLAG_DECODE
SOUND_FLAG_ASYNC = lib.MA_SOUND_FLAG_ASYNC
SOUND_FLAG_NO_PITCH = lib.MA_SOUND_FLAG_NO_PITCH
SOUND_FLAG_NO_SPATIALIZATION = lib.MA_SOUND_FLAG_NO_SPATIALIZATION


cdef class Sound:
    """
    A playable sound loaded from a file.

    Sounds provide full control over playback including volume, pitch, pan,
    looping, seeking, and 3D spatialization.

    Example:
        engine = Engine()
        sound = Sound(engine, "music.mp3")
        sound.volume = 0.8
        sound.looping = True
        sound.start()
    """
    cdef lib.ma_sound _sound
    cdef Engine _engine
    cdef bint _initialized
    cdef str _path

    def __cinit__(self):
        self._initialized = False
        self._engine = None

    def __init__(self, Engine engine not None, str path, lib.ma_uint32 flags=0):
        """
        Load a sound from a file.

        Args:
            engine: The Engine instance to use
            path: Path to the audio file
            flags: Sound flags (SOUND_FLAG_STREAM, SOUND_FLAG_DECODE, etc.)
        """
        if not engine._initialized:
            raise EngineError("Engine not initialized")

        cdef bytes path_bytes = path.encode('utf-8')
        cdef lib.ma_result result

        result = lib.ma_sound_init_from_file(
            &engine._engine,
            path_bytes,
            flags,
            NULL,  # pGroup
            NULL,  # pDoneFence
            &self._sound
        )
        if result != lib.MA_SUCCESS:
            raise SoundError(f"Failed to load sound '{path}' (error {result})")

        self._engine = engine
        self._initialized = True
        self._path = path

    def __dealloc__(self):
        if self._initialized:
            lib.ma_sound_uninit(&self._sound)
            self._initialized = False

    def close(self):
        """Close the sound and release resources."""
        if self._initialized:
            lib.ma_sound_uninit(&self._sound)
            self._initialized = False

    @property
    def path(self) -> str:
        """Get the file path this sound was loaded from."""
        return self._path

    # Playback control

    def start(self):
        """Start or resume playback."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        cdef lib.ma_result result = lib.ma_sound_start(&self._sound)
        _check_result(result)

    def stop(self):
        """Stop playback."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        cdef lib.ma_result result = lib.ma_sound_stop(&self._sound)
        _check_result(result)

    def stop_with_fade(self, lib.ma_uint64 fade_ms):
        """Stop playback with a fade out."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        cdef lib.ma_result result = lib.ma_sound_stop_with_fade_in_milliseconds(&self._sound, fade_ms)
        _check_result(result)

    @property
    def is_playing(self) -> bool:
        """Check if the sound is currently playing."""
        if not self._initialized:
            return False
        return bool(lib.ma_sound_is_playing(&self._sound))

    @property
    def at_end(self) -> bool:
        """Check if playback has reached the end."""
        if not self._initialized:
            return True
        return bool(lib.ma_sound_at_end(&self._sound))

    # Volume and panning

    @property
    def volume(self) -> float:
        """Get the volume (0.0 to 1.0+)."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_volume(&self._sound)

    @volume.setter
    def volume(self, float value):
        """Set the volume (0.0 to 1.0+)."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_volume(&self._sound, value)

    @property
    def pan(self) -> float:
        """Get the pan (-1.0 left to 1.0 right)."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_pan(&self._sound)

    @pan.setter
    def pan(self, float value):
        """Set the pan (-1.0 left to 1.0 right)."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_pan(&self._sound, value)

    @property
    def pitch(self) -> float:
        """Get the pitch multiplier."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_pitch(&self._sound)

    @pitch.setter
    def pitch(self, float value):
        """Set the pitch multiplier (1.0 = normal, 2.0 = octave up)."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_pitch(&self._sound, value)

    # Looping

    @property
    def looping(self) -> bool:
        """Get whether the sound loops."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return bool(lib.ma_sound_is_looping(&self._sound))

    @looping.setter
    def looping(self, bint value):
        """Set whether the sound loops."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_looping(&self._sound, value)

    # Seeking and position

    def seek(self, lib.ma_uint64 frame):
        """Seek to a specific PCM frame."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        cdef lib.ma_result result = lib.ma_sound_seek_to_pcm_frame(&self._sound, frame)
        _check_result(result)

    @property
    def cursor(self) -> int:
        """Get the current playback position in PCM frames."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        cdef lib.ma_uint64 cursor
        cdef lib.ma_result result = lib.ma_sound_get_cursor_in_pcm_frames(&self._sound, &cursor)
        _check_result(result)
        return cursor

    @property
    def cursor_seconds(self) -> float:
        """Get the current playback position in seconds."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        cdef float cursor
        cdef lib.ma_result result = lib.ma_sound_get_cursor_in_seconds(&self._sound, &cursor)
        _check_result(result)
        return cursor

    @property
    def length(self) -> int:
        """Get the total length in PCM frames."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        cdef lib.ma_uint64 length
        cdef lib.ma_result result = lib.ma_sound_get_length_in_pcm_frames(&self._sound, &length)
        _check_result(result)
        return length

    @property
    def length_seconds(self) -> float:
        """Get the total length in seconds."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        cdef float length
        cdef lib.ma_result result = lib.ma_sound_get_length_in_seconds(&self._sound, &length)
        _check_result(result)
        return length

    @property
    def time(self) -> int:
        """Get the local time in PCM frames."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_time_in_pcm_frames(&self._sound)

    @property
    def time_ms(self) -> int:
        """Get the local time in milliseconds."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_time_in_milliseconds(&self._sound)

    # Fading

    def fade(self, float start_volume, float end_volume, lib.ma_uint64 duration_ms):
        """
        Apply a volume fade.

        Args:
            start_volume: Starting volume
            end_volume: Ending volume
            duration_ms: Fade duration in milliseconds
        """
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_fade_in_milliseconds(&self._sound, start_volume, end_volume, duration_ms)

    @property
    def current_fade_volume(self) -> float:
        """Get the current fade volume."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_current_fade_volume(&self._sound)

    # Scheduled playback

    def set_start_time(self, lib.ma_uint64 time_ms):
        """Schedule the sound to start at a specific time (in milliseconds)."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_start_time_in_milliseconds(&self._sound, time_ms)

    def set_stop_time(self, lib.ma_uint64 time_ms):
        """Schedule the sound to stop at a specific time (in milliseconds)."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_stop_time_in_milliseconds(&self._sound, time_ms)

    def set_stop_time_with_fade(self, lib.ma_uint64 stop_time_ms, lib.ma_uint64 fade_ms):
        """Schedule the sound to stop with a fade at a specific time."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_stop_time_with_fade_in_milliseconds(&self._sound, stop_time_ms, fade_ms)

    # 3D Spatialization

    @property
    def spatialization_enabled(self) -> bool:
        """Get whether 3D spatialization is enabled."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return bool(lib.ma_sound_is_spatialization_enabled(&self._sound))

    @spatialization_enabled.setter
    def spatialization_enabled(self, bint value):
        """Enable or disable 3D spatialization."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_spatialization_enabled(&self._sound, value)

    def set_position(self, float x, float y, float z):
        """Set the 3D position of the sound."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_position(&self._sound, x, y, z)

    def set_direction(self, float x, float y, float z):
        """Set the direction the sound is facing."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_direction(&self._sound, x, y, z)

    def set_velocity(self, float x, float y, float z):
        """Set the velocity for doppler effect."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_velocity(&self._sound, x, y, z)

    @property
    def attenuation_model(self) -> int:
        """Get the distance attenuation model."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_attenuation_model(&self._sound)

    @attenuation_model.setter
    def attenuation_model(self, lib.ma_attenuation_model value):
        """Set the distance attenuation model."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_attenuation_model(&self._sound, value)

    @property
    def rolloff(self) -> float:
        """Get the rolloff factor for distance attenuation."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_rolloff(&self._sound)

    @rolloff.setter
    def rolloff(self, float value):
        """Set the rolloff factor for distance attenuation."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_rolloff(&self._sound, value)

    @property
    def min_distance(self) -> float:
        """Get the minimum distance for attenuation."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_min_distance(&self._sound)

    @min_distance.setter
    def min_distance(self, float value):
        """Set the minimum distance for attenuation."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_min_distance(&self._sound, value)

    @property
    def max_distance(self) -> float:
        """Get the maximum distance for attenuation."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_max_distance(&self._sound)

    @max_distance.setter
    def max_distance(self, float value):
        """Set the maximum distance for attenuation."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_max_distance(&self._sound, value)

    @property
    def min_gain(self) -> float:
        """Get the minimum gain."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_min_gain(&self._sound)

    @min_gain.setter
    def min_gain(self, float value):
        """Set the minimum gain."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_min_gain(&self._sound, value)

    @property
    def max_gain(self) -> float:
        """Get the maximum gain."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_max_gain(&self._sound)

    @max_gain.setter
    def max_gain(self, float value):
        """Set the maximum gain."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_max_gain(&self._sound, value)

    @property
    def doppler_factor(self) -> float:
        """Get the doppler factor."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        return lib.ma_sound_get_doppler_factor(&self._sound)

    @doppler_factor.setter
    def doppler_factor(self, float value):
        """Set the doppler factor (0 = disabled)."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_doppler_factor(&self._sound, value)

    def set_cone(self, float inner_angle, float outer_angle, float outer_gain):
        """
        Set the sound's directional cone.

        Args:
            inner_angle: Inner cone angle in radians
            outer_angle: Outer cone angle in radians
            outer_gain: Gain applied outside the outer cone
        """
        if not self._initialized:
            raise SoundError("Sound not initialized")
        lib.ma_sound_set_cone(&self._sound, inner_angle, outer_angle, outer_gain)

    def get_cone(self) -> Tuple[float, float, float]:
        """Get the sound's directional cone (inner_angle, outer_angle, outer_gain)."""
        if not self._initialized:
            raise SoundError("Sound not initialized")
        cdef float inner, outer, gain
        lib.ma_sound_get_cone(&self._sound, &inner, &outer, &gain)
        return (inner, outer, gain)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
        return False

    def __repr__(self):
        status = "playing" if self.is_playing else "stopped"
        return f"Sound({self._path!r}, {status})"


# -----------------------------------------------------------------------------
# Waveform Generator
# -----------------------------------------------------------------------------

cdef class Waveform:
    """
    Procedural waveform generator.

    Generates sine, square, triangle, or sawtooth waveforms.

    Example:
        waveform = Waveform(WaveformType.SINE, amplitude=0.5, frequency=440)
        frames = waveform.read(1024)
    """
    cdef lib.ma_waveform _waveform
    cdef bint _initialized
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False

    def __init__(self, int waveform_type=WaveformType.SINE,
                 double amplitude=0.5, double frequency=440.0,
                 int channels=2, int sample_rate=48000):
        """
        Initialize a waveform generator.

        Args:
            waveform_type: Type of waveform (SINE, SQUARE, TRIANGLE, SAWTOOTH)
            amplitude: Amplitude (0.0 to 1.0)
            frequency: Frequency in Hz
            channels: Number of channels
            sample_rate: Sample rate in Hz
        """
        cdef lib.ma_waveform_config config
        cdef lib.ma_result result

        config = lib.ma_waveform_config_init(
            lib.ma_format_f32,
            channels,
            sample_rate,
            <lib.ma_waveform_type>waveform_type,
            amplitude,
            frequency
        )

        result = lib.ma_waveform_init(&config, &self._waveform)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize waveform (error {result})")

        self._initialized = True
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_waveform_uninit(&self._waveform)
            self._initialized = False

    @property
    def amplitude(self) -> float:
        """Get the current amplitude."""
        if not self._initialized:
            raise MinimaError("Waveform not initialized")
        return self._waveform.config.amplitude

    @amplitude.setter
    def amplitude(self, double value):
        """Set the amplitude."""
        if not self._initialized:
            raise MinimaError("Waveform not initialized")
        lib.ma_waveform_set_amplitude(&self._waveform, value)

    @property
    def frequency(self) -> float:
        """Get the current frequency."""
        if not self._initialized:
            raise MinimaError("Waveform not initialized")
        return self._waveform.config.frequency

    @frequency.setter
    def frequency(self, double value):
        """Set the frequency."""
        if not self._initialized:
            raise MinimaError("Waveform not initialized")
        lib.ma_waveform_set_frequency(&self._waveform, value)

    @property
    def waveform_type(self) -> int:
        """Get the waveform type."""
        if not self._initialized:
            raise MinimaError("Waveform not initialized")
        return self._waveform.config.type

    @waveform_type.setter
    def waveform_type(self, int value):
        """Set the waveform type."""
        if not self._initialized:
            raise MinimaError("Waveform not initialized")
        lib.ma_waveform_set_type(&self._waveform, <lib.ma_waveform_type>value)

    def seek(self, lib.ma_uint64 frame):
        """Seek to a specific PCM frame."""
        if not self._initialized:
            raise MinimaError("Waveform not initialized")
        with nogil:
            lib.ma_waveform_seek_to_pcm_frame(&self._waveform, frame)

    def read(self, lib.ma_uint64 frame_count) -> bytes:
        """
        Read PCM frames from the waveform generator.

        Args:
            frame_count: Number of frames to read

        Returns:
            bytes containing float32 PCM data
        """
        if not self._initialized:
            raise MinimaError("Waveform not initialized")

        cdef lib.ma_uint64 frames_read
        cdef size_t buffer_size = frame_count * self._channels * sizeof(float)
        cdef float* buffer = <float*>malloc(buffer_size)

        if buffer == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_waveform_read_pcm_frames(&self._waveform, buffer, frame_count, &frames_read)
            return bytes((<char*>buffer)[:frames_read * self._channels * sizeof(float)])
        finally:
            free(buffer)


# -----------------------------------------------------------------------------
# Noise Generator
# -----------------------------------------------------------------------------

cdef class Noise:
    """
    Procedural noise generator.

    Generates white, pink, or brownian noise.

    Example:
        noise = Noise(NoiseType.WHITE, amplitude=0.3)
        frames = noise.read(1024)
    """
    cdef lib.ma_noise _noise
    cdef bint _initialized
    cdef lib.ma_uint32 _channels

    def __cinit__(self):
        self._initialized = False

    def __init__(self, int noise_type=NoiseType.WHITE,
                 double amplitude=0.5, int seed=0,
                 int channels=2):
        """
        Initialize a noise generator.

        Args:
            noise_type: Type of noise (WHITE, PINK, BROWNIAN)
            amplitude: Amplitude (0.0 to 1.0)
            seed: Random seed (0 for auto)
            channels: Number of channels
        """
        cdef lib.ma_noise_config config
        cdef lib.ma_result result

        config = lib.ma_noise_config_init(
            lib.ma_format_f32,
            channels,
            <lib.ma_noise_type>noise_type,
            seed,
            amplitude
        )

        result = lib.ma_noise_init(&config, NULL, &self._noise)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize noise (error {result})")

        self._initialized = True
        self._channels = channels

    def __dealloc__(self):
        if self._initialized:
            lib.ma_noise_uninit(&self._noise, NULL)
            self._initialized = False

    @property
    def amplitude(self) -> float:
        """Get the current amplitude."""
        if not self._initialized:
            raise MinimaError("Noise not initialized")
        return self._noise.config.amplitude

    @amplitude.setter
    def amplitude(self, double value):
        """Set the amplitude."""
        if not self._initialized:
            raise MinimaError("Noise not initialized")
        lib.ma_noise_set_amplitude(&self._noise, value)

    @property
    def noise_type(self) -> int:
        """Get the noise type."""
        if not self._initialized:
            raise MinimaError("Noise not initialized")
        return self._noise.config.type

    @noise_type.setter
    def noise_type(self, int value):
        """Set the noise type."""
        if not self._initialized:
            raise MinimaError("Noise not initialized")
        lib.ma_noise_set_type(&self._noise, <lib.ma_noise_type>value)

    def set_seed(self, int seed):
        """Set the random seed."""
        if not self._initialized:
            raise MinimaError("Noise not initialized")
        lib.ma_noise_set_seed(&self._noise, seed)

    def read(self, lib.ma_uint64 frame_count) -> bytes:
        """
        Read PCM frames from the noise generator.

        Args:
            frame_count: Number of frames to read

        Returns:
            bytes containing float32 PCM data
        """
        if not self._initialized:
            raise MinimaError("Noise not initialized")

        cdef lib.ma_uint64 frames_read
        cdef size_t buffer_size = frame_count * self._channels * sizeof(float)
        cdef float* buffer = <float*>malloc(buffer_size)

        if buffer == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_noise_read_pcm_frames(&self._noise, buffer, frame_count, &frames_read)
            return bytes((<char*>buffer)[:frames_read * self._channels * sizeof(float)])
        finally:
            free(buffer)


# -----------------------------------------------------------------------------
# Decoder Class
# -----------------------------------------------------------------------------

cdef class Decoder:
    """
    Audio file decoder.

    Decodes audio files to PCM data for processing or analysis.

    Example:
        decoder = Decoder("music.mp3")
        print(f"Duration: {decoder.length_seconds}s")
        frames = decoder.read(1024)
    """
    cdef lib.ma_decoder _decoder
    cdef bint _initialized
    cdef str _path

    def __cinit__(self):
        self._initialized = False

    def __init__(self, str path, int output_format=Format.F32,
                 int output_channels=0, int output_sample_rate=0):
        """
        Open an audio file for decoding.

        Args:
            path: Path to the audio file
            output_format: Desired output format (default: F32)
            output_channels: Desired output channels (0 = native)
            output_sample_rate: Desired output sample rate (0 = native)
        """
        cdef lib.ma_decoder_config config
        cdef lib.ma_result result
        cdef bytes path_bytes = path.encode('utf-8')

        config = lib.ma_decoder_config_init(
            <lib.ma_format>output_format,
            output_channels,
            output_sample_rate
        )

        result = lib.ma_decoder_init_file(path_bytes, &config, &self._decoder)
        if result != lib.MA_SUCCESS:
            raise DecoderError(f"Failed to open '{path}' for decoding (error {result})")

        self._initialized = True
        self._path = path

    def __dealloc__(self):
        if self._initialized:
            lib.ma_decoder_uninit(&self._decoder)
            self._initialized = False

    def close(self):
        """Close the decoder and release resources."""
        if self._initialized:
            lib.ma_decoder_uninit(&self._decoder)
            self._initialized = False

    @property
    def path(self) -> str:
        """Get the file path."""
        return self._path

    @property
    def format(self) -> int:
        """Get the output sample format."""
        if not self._initialized:
            raise DecoderError("Decoder not initialized")
        return self._decoder.outputFormat

    @property
    def channels(self) -> int:
        """Get the number of output channels."""
        if not self._initialized:
            raise DecoderError("Decoder not initialized")
        return self._decoder.outputChannels

    @property
    def sample_rate(self) -> int:
        """Get the output sample rate."""
        if not self._initialized:
            raise DecoderError("Decoder not initialized")
        return self._decoder.outputSampleRate

    @property
    def cursor(self) -> int:
        """Get the current position in PCM frames."""
        if not self._initialized:
            raise DecoderError("Decoder not initialized")
        cdef lib.ma_uint64 cursor
        cdef lib.ma_result result = lib.ma_decoder_get_cursor_in_pcm_frames(&self._decoder, &cursor)
        _check_result(result)
        return cursor

    @property
    def length(self) -> int:
        """Get the total length in PCM frames."""
        if not self._initialized:
            raise DecoderError("Decoder not initialized")
        cdef lib.ma_uint64 length
        cdef lib.ma_result result = lib.ma_decoder_get_length_in_pcm_frames(&self._decoder, &length)
        _check_result(result)
        return length

    @property
    def length_seconds(self) -> float:
        """Get the total length in seconds."""
        if not self._initialized:
            raise DecoderError("Decoder not initialized")
        cdef lib.ma_uint64 length
        cdef lib.ma_result result = lib.ma_decoder_get_length_in_pcm_frames(&self._decoder, &length)
        _check_result(result)
        return length / float(self._decoder.outputSampleRate)

    def seek(self, lib.ma_uint64 frame):
        """Seek to a specific PCM frame."""
        if not self._initialized:
            raise DecoderError("Decoder not initialized")
        cdef lib.ma_result result
        with nogil:
            result = lib.ma_decoder_seek_to_pcm_frame(&self._decoder, frame)
        _check_result(result)

    def read(self, lib.ma_uint64 frame_count) -> bytes:
        """
        Read PCM frames from the decoder.

        Args:
            frame_count: Number of frames to read

        Returns:
            bytes containing PCM data in the output format
        """
        if not self._initialized:
            raise DecoderError("Decoder not initialized")

        cdef lib.ma_uint64 frames_read
        cdef int bytes_per_sample
        cdef size_t buffer_size
        cdef void* buffer

        # Calculate bytes per sample based on format
        if self._decoder.outputFormat == lib.ma_format_u8:
            bytes_per_sample = 1
        elif self._decoder.outputFormat == lib.ma_format_s16:
            bytes_per_sample = 2
        elif self._decoder.outputFormat == lib.ma_format_s24:
            bytes_per_sample = 3
        elif self._decoder.outputFormat == lib.ma_format_s32:
            bytes_per_sample = 4
        else:  # f32
            bytes_per_sample = 4

        buffer_size = frame_count * self._decoder.outputChannels * bytes_per_sample
        buffer = malloc(buffer_size)

        if buffer == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_decoder_read_pcm_frames(&self._decoder, buffer, frame_count, &frames_read)
            return bytes((<char*>buffer)[:frames_read * self._decoder.outputChannels * bytes_per_sample])
        finally:
            free(buffer)

    def read_all(self) -> bytes:
        """Read all remaining PCM frames from the decoder."""
        if not self._initialized:
            raise DecoderError("Decoder not initialized")

        # Read in chunks
        chunks = []
        while True:
            chunk = self.read(4096)
            if not chunk:
                break
            chunks.append(chunk)

        return b''.join(chunks)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
        return False

    def __repr__(self):
        return f"Decoder({self._path!r}, {self.channels}ch, {self.sample_rate}Hz)"


# -----------------------------------------------------------------------------
# Filters
# -----------------------------------------------------------------------------

cdef class LowPassFilter:
    """
    Low-pass filter that attenuates frequencies above the cutoff.

    Example:
        lpf = LowPassFilter(cutoff=1000.0, order=2)
        output = lpf.process(input_data)
    """
    cdef lib.ma_lpf _filter
    cdef bint _initialized
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False

    def __init__(self, double cutoff, int order=2,
                 int channels=2, int sample_rate=48000,
                 int format=Format.F32):
        """
        Initialize a low-pass filter.

        Args:
            cutoff: Cutoff frequency in Hz
            order: Filter order (1-8, higher = steeper rolloff)
            channels: Number of channels
            sample_rate: Sample rate in Hz
            format: Sample format
        """
        cdef lib.ma_lpf_config config
        cdef lib.ma_result result

        config = lib.ma_lpf_config_init(
            <lib.ma_format>format,
            channels,
            sample_rate,
            cutoff,
            order
        )

        result = lib.ma_lpf_init(&config, NULL, &self._filter)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize low-pass filter (error {result})")

        self._initialized = True
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_lpf_uninit(&self._filter, NULL)
            self._initialized = False

    def reinit(self, double cutoff, int order=2):
        """Reinitialize the filter with new parameters."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        cdef lib.ma_lpf_config config = lib.ma_lpf_config_init(
            self._filter.format,
            self._channels,
            self._sample_rate,
            cutoff,
            order
        )
        cdef lib.ma_result result = lib.ma_lpf_reinit(&config, &self._filter)
        _check_result(result)

    def process(self, bytes data) -> bytes:
        """
        Process audio data through the filter.

        Args:
            data: Input PCM data (float32)

        Returns:
            Filtered PCM data
        """
        if not self._initialized:
            raise MinimaError("Filter not initialized")

        cdef lib.ma_uint64 frame_count = len(data) // (self._channels * sizeof(float))
        cdef size_t data_len = len(data)
        cdef const char* input_ptr = <const char*>data
        cdef float* output = <float*>malloc(data_len)

        if output == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_lpf_process_pcm_frames(&self._filter, output, <float*>input_ptr, frame_count)
            return bytes((<char*>output)[:data_len])
        finally:
            free(output)

    @property
    def latency(self) -> int:
        """Get the filter latency in frames."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        return lib.ma_lpf_get_latency(&self._filter)


cdef class HighPassFilter:
    """
    High-pass filter that attenuates frequencies below the cutoff.

    Example:
        hpf = HighPassFilter(cutoff=200.0, order=2)
        output = hpf.process(input_data)
    """
    cdef lib.ma_hpf _filter
    cdef bint _initialized
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False

    def __init__(self, double cutoff, int order=2,
                 int channels=2, int sample_rate=48000,
                 int format=Format.F32):
        """
        Initialize a high-pass filter.

        Args:
            cutoff: Cutoff frequency in Hz
            order: Filter order (1-8, higher = steeper rolloff)
            channels: Number of channels
            sample_rate: Sample rate in Hz
            format: Sample format
        """
        cdef lib.ma_hpf_config config
        cdef lib.ma_result result

        config = lib.ma_hpf_config_init(
            <lib.ma_format>format,
            channels,
            sample_rate,
            cutoff,
            order
        )

        result = lib.ma_hpf_init(&config, NULL, &self._filter)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize high-pass filter (error {result})")

        self._initialized = True
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_hpf_uninit(&self._filter, NULL)
            self._initialized = False

    def reinit(self, double cutoff, int order=2):
        """Reinitialize the filter with new parameters."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        cdef lib.ma_hpf_config config = lib.ma_hpf_config_init(
            self._filter.format,
            self._channels,
            self._sample_rate,
            cutoff,
            order
        )
        cdef lib.ma_result result = lib.ma_hpf_reinit(&config, &self._filter)
        _check_result(result)

    def process(self, bytes data) -> bytes:
        """Process audio data through the filter."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")

        cdef lib.ma_uint64 frame_count = len(data) // (self._channels * sizeof(float))
        cdef size_t data_len = len(data)
        cdef const char* input_ptr = <const char*>data
        cdef float* output = <float*>malloc(data_len)

        if output == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_hpf_process_pcm_frames(&self._filter, output, <float*>input_ptr, frame_count)
            return bytes((<char*>output)[:data_len])
        finally:
            free(output)

    @property
    def latency(self) -> int:
        """Get the filter latency in frames."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        return lib.ma_hpf_get_latency(&self._filter)


cdef class BandPassFilter:
    """
    Band-pass filter that passes frequencies within a range.

    Example:
        bpf = BandPassFilter(cutoff=1000.0, order=2)
        output = bpf.process(input_data)
    """
    cdef lib.ma_bpf _filter
    cdef bint _initialized
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False

    def __init__(self, double cutoff, int order=2,
                 int channels=2, int sample_rate=48000,
                 int format=Format.F32):
        """
        Initialize a band-pass filter.

        Args:
            cutoff: Center frequency in Hz
            order: Filter order (must be even, 2-8)
            channels: Number of channels
            sample_rate: Sample rate in Hz
            format: Sample format
        """
        cdef lib.ma_bpf_config config
        cdef lib.ma_result result

        config = lib.ma_bpf_config_init(
            <lib.ma_format>format,
            channels,
            sample_rate,
            cutoff,
            order
        )

        result = lib.ma_bpf_init(&config, NULL, &self._filter)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize band-pass filter (error {result})")

        self._initialized = True
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_bpf_uninit(&self._filter, NULL)
            self._initialized = False

    def reinit(self, double cutoff, int order=2):
        """Reinitialize the filter with new parameters."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        cdef lib.ma_bpf_config config = lib.ma_bpf_config_init(
            self._filter.format,
            self._channels,
            self._sample_rate,
            cutoff,
            order
        )
        cdef lib.ma_result result = lib.ma_bpf_reinit(&config, &self._filter)
        _check_result(result)

    def process(self, bytes data) -> bytes:
        """Process audio data through the filter."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")

        cdef lib.ma_uint64 frame_count = len(data) // (self._channels * sizeof(float))
        cdef size_t data_len = len(data)
        cdef const char* input_ptr = <const char*>data
        cdef float* output = <float*>malloc(data_len)

        if output == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_bpf_process_pcm_frames(&self._filter, output, <float*>input_ptr, frame_count)
            return bytes((<char*>output)[:data_len])
        finally:
            free(output)

    @property
    def latency(self) -> int:
        """Get the filter latency in frames."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        return lib.ma_bpf_get_latency(&self._filter)


cdef class NotchFilter:
    """
    Notch filter (band-reject) that attenuates a specific frequency.

    Example:
        notch = NotchFilter(frequency=60.0, q=10.0)  # Remove 60Hz hum
        output = notch.process(input_data)
    """
    cdef lib.ma_notch2 _filter
    cdef bint _initialized
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False

    def __init__(self, double frequency, double q=1.0,
                 int channels=2, int sample_rate=48000,
                 int format=Format.F32):
        """
        Initialize a notch filter.

        Args:
            frequency: Center frequency to attenuate in Hz
            q: Q factor (higher = narrower notch)
            channels: Number of channels
            sample_rate: Sample rate in Hz
            format: Sample format
        """
        cdef lib.ma_notch2_config config
        cdef lib.ma_result result

        config = lib.ma_notch2_config_init(
            <lib.ma_format>format,
            channels,
            sample_rate,
            q,
            frequency
        )

        result = lib.ma_notch2_init(&config, NULL, &self._filter)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize notch filter (error {result})")

        self._initialized = True
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_notch2_uninit(&self._filter, NULL)
            self._initialized = False

    def reinit(self, double frequency, double q=1.0):
        """Reinitialize the filter with new parameters."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        cdef lib.ma_notch2_config config = lib.ma_notch2_config_init(
            lib.ma_format_f32,
            self._channels,
            self._sample_rate,
            q,
            frequency
        )
        cdef lib.ma_result result = lib.ma_notch2_reinit(&config, &self._filter)
        _check_result(result)

    def process(self, bytes data) -> bytes:
        """Process audio data through the filter."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")

        cdef lib.ma_uint64 frame_count = len(data) // (self._channels * sizeof(float))
        cdef size_t data_len = len(data)
        cdef const char* input_ptr = <const char*>data
        cdef float* output = <float*>malloc(data_len)

        if output == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_notch2_process_pcm_frames(&self._filter, output, <float*>input_ptr, frame_count)
            return bytes((<char*>output)[:data_len])
        finally:
            free(output)

    @property
    def latency(self) -> int:
        """Get the filter latency in frames."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        return lib.ma_notch2_get_latency(&self._filter)


cdef class PeakFilter:
    """
    Peaking EQ filter that boosts or cuts a specific frequency.

    Example:
        peak = PeakFilter(frequency=1000.0, gain_db=6.0, q=1.0)
        output = peak.process(input_data)
    """
    cdef lib.ma_peak2 _filter
    cdef bint _initialized
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False

    def __init__(self, double frequency, double gain_db=0.0, double q=1.0,
                 int channels=2, int sample_rate=48000,
                 int format=Format.F32):
        """
        Initialize a peaking EQ filter.

        Args:
            frequency: Center frequency in Hz
            gain_db: Gain in decibels (positive = boost, negative = cut)
            q: Q factor (higher = narrower band)
            channels: Number of channels
            sample_rate: Sample rate in Hz
            format: Sample format
        """
        cdef lib.ma_peak2_config config
        cdef lib.ma_result result

        config = lib.ma_peak2_config_init(
            <lib.ma_format>format,
            channels,
            sample_rate,
            gain_db,
            q,
            frequency
        )

        result = lib.ma_peak2_init(&config, NULL, &self._filter)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize peak filter (error {result})")

        self._initialized = True
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_peak2_uninit(&self._filter, NULL)
            self._initialized = False

    def reinit(self, double frequency, double gain_db=0.0, double q=1.0):
        """Reinitialize the filter with new parameters."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        cdef lib.ma_peak2_config config = lib.ma_peak2_config_init(
            lib.ma_format_f32,
            self._channels,
            self._sample_rate,
            gain_db,
            q,
            frequency
        )
        cdef lib.ma_result result = lib.ma_peak2_reinit(&config, &self._filter)
        _check_result(result)

    def process(self, bytes data) -> bytes:
        """Process audio data through the filter."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")

        cdef lib.ma_uint64 frame_count = len(data) // (self._channels * sizeof(float))
        cdef size_t data_len = len(data)
        cdef const char* input_ptr = <const char*>data
        cdef float* output = <float*>malloc(data_len)

        if output == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_peak2_process_pcm_frames(&self._filter, output, <float*>input_ptr, frame_count)
            return bytes((<char*>output)[:data_len])
        finally:
            free(output)

    @property
    def latency(self) -> int:
        """Get the filter latency in frames."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        return lib.ma_peak2_get_latency(&self._filter)


cdef class LowShelfFilter:
    """
    Low shelf filter that boosts or cuts frequencies below a threshold.

    Example:
        loshelf = LowShelfFilter(frequency=200.0, gain_db=3.0)
        output = loshelf.process(input_data)
    """
    cdef lib.ma_loshelf2 _filter
    cdef bint _initialized
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False

    def __init__(self, double frequency, double gain_db=0.0, double slope=1.0,
                 int channels=2, int sample_rate=48000,
                 int format=Format.F32):
        """
        Initialize a low shelf filter.

        Args:
            frequency: Shelf frequency in Hz
            gain_db: Gain in decibels (positive = boost, negative = cut)
            slope: Shelf slope (0.0 to 1.0)
            channels: Number of channels
            sample_rate: Sample rate in Hz
            format: Sample format
        """
        cdef lib.ma_loshelf2_config config
        cdef lib.ma_result result

        config = lib.ma_loshelf2_config_init(
            <lib.ma_format>format,
            channels,
            sample_rate,
            gain_db,
            slope,
            frequency
        )

        result = lib.ma_loshelf2_init(&config, NULL, &self._filter)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize low shelf filter (error {result})")

        self._initialized = True
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_loshelf2_uninit(&self._filter, NULL)
            self._initialized = False

    def reinit(self, double frequency, double gain_db=0.0, double slope=1.0):
        """Reinitialize the filter with new parameters."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        cdef lib.ma_loshelf2_config config = lib.ma_loshelf2_config_init(
            lib.ma_format_f32,
            self._channels,
            self._sample_rate,
            gain_db,
            slope,
            frequency
        )
        cdef lib.ma_result result = lib.ma_loshelf2_reinit(&config, &self._filter)
        _check_result(result)

    def process(self, bytes data) -> bytes:
        """Process audio data through the filter."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")

        cdef lib.ma_uint64 frame_count = len(data) // (self._channels * sizeof(float))
        cdef size_t data_len = len(data)
        cdef const char* input_ptr = <const char*>data
        cdef float* output = <float*>malloc(data_len)

        if output == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_loshelf2_process_pcm_frames(&self._filter, output, <float*>input_ptr, frame_count)
            return bytes((<char*>output)[:data_len])
        finally:
            free(output)

    @property
    def latency(self) -> int:
        """Get the filter latency in frames."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        return lib.ma_loshelf2_get_latency(&self._filter)


cdef class HighShelfFilter:
    """
    High shelf filter that boosts or cuts frequencies above a threshold.

    Example:
        hishelf = HighShelfFilter(frequency=8000.0, gain_db=-3.0)
        output = hishelf.process(input_data)
    """
    cdef lib.ma_hishelf2 _filter
    cdef bint _initialized
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False

    def __init__(self, double frequency, double gain_db=0.0, double slope=1.0,
                 int channels=2, int sample_rate=48000,
                 int format=Format.F32):
        """
        Initialize a high shelf filter.

        Args:
            frequency: Shelf frequency in Hz
            gain_db: Gain in decibels (positive = boost, negative = cut)
            slope: Shelf slope (0.0 to 1.0)
            channels: Number of channels
            sample_rate: Sample rate in Hz
            format: Sample format
        """
        cdef lib.ma_hishelf2_config config
        cdef lib.ma_result result

        config = lib.ma_hishelf2_config_init(
            <lib.ma_format>format,
            channels,
            sample_rate,
            gain_db,
            slope,
            frequency
        )

        result = lib.ma_hishelf2_init(&config, NULL, &self._filter)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize high shelf filter (error {result})")

        self._initialized = True
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_hishelf2_uninit(&self._filter, NULL)
            self._initialized = False

    def reinit(self, double frequency, double gain_db=0.0, double slope=1.0):
        """Reinitialize the filter with new parameters."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        cdef lib.ma_hishelf2_config config = lib.ma_hishelf2_config_init(
            lib.ma_format_f32,
            self._channels,
            self._sample_rate,
            gain_db,
            slope,
            frequency
        )
        cdef lib.ma_result result = lib.ma_hishelf2_reinit(&config, &self._filter)
        _check_result(result)

    def process(self, bytes data) -> bytes:
        """Process audio data through the filter."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")

        cdef lib.ma_uint64 frame_count = len(data) // (self._channels * sizeof(float))
        cdef size_t data_len = len(data)
        cdef const char* input_ptr = <const char*>data
        cdef float* output = <float*>malloc(data_len)

        if output == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_hishelf2_process_pcm_frames(&self._filter, output, <float*>input_ptr, frame_count)
            return bytes((<char*>output)[:data_len])
        finally:
            free(output)

    @property
    def latency(self) -> int:
        """Get the filter latency in frames."""
        if not self._initialized:
            raise MinimaError("Filter not initialized")
        return lib.ma_hishelf2_get_latency(&self._filter)


# -----------------------------------------------------------------------------
# Delay Effect
# -----------------------------------------------------------------------------

cdef class Delay:
    """
    Audio delay effect.

    Example:
        delay = Delay(delay_ms=250, wet=0.5, decay=0.5)
        output = delay.process(input_data)
    """
    cdef lib.ma_delay _delay
    cdef bint _initialized
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False

    def __init__(self, double delay_ms=250.0, float wet=0.5, float decay=0.5,
                 float dry=1.0, bint delay_start=True,
                 int channels=2, int sample_rate=48000):
        """
        Initialize a delay effect.

        Args:
            delay_ms: Delay time in milliseconds
            wet: Wet (delayed) signal level (0.0 to 1.0)
            decay: Feedback decay (0.0 to 1.0, 0 = no feedback)
            dry: Dry (original) signal level (0.0 to 1.0)
            delay_start: Whether to delay the first output
            channels: Number of channels
            sample_rate: Sample rate in Hz
        """
        cdef lib.ma_delay_config config
        cdef lib.ma_result result
        cdef lib.ma_uint32 delay_frames = <lib.ma_uint32>(delay_ms * sample_rate / 1000.0)

        config = lib.ma_delay_config_init(channels, sample_rate, delay_frames, decay)
        config.wet = wet
        config.dry = dry
        config.delayStart = delay_start

        result = lib.ma_delay_init(&config, NULL, &self._delay)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize delay (error {result})")

        self._initialized = True
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_delay_uninit(&self._delay, NULL)
            self._initialized = False

    @property
    def wet(self) -> float:
        """Get the wet signal level."""
        if not self._initialized:
            raise MinimaError("Delay not initialized")
        return lib.ma_delay_get_wet(&self._delay)

    @wet.setter
    def wet(self, float value):
        """Set the wet signal level."""
        if not self._initialized:
            raise MinimaError("Delay not initialized")
        lib.ma_delay_set_wet(&self._delay, value)

    @property
    def dry(self) -> float:
        """Get the dry signal level."""
        if not self._initialized:
            raise MinimaError("Delay not initialized")
        return lib.ma_delay_get_dry(&self._delay)

    @dry.setter
    def dry(self, float value):
        """Set the dry signal level."""
        if not self._initialized:
            raise MinimaError("Delay not initialized")
        lib.ma_delay_set_dry(&self._delay, value)

    @property
    def decay(self) -> float:
        """Get the feedback decay."""
        if not self._initialized:
            raise MinimaError("Delay not initialized")
        return lib.ma_delay_get_decay(&self._delay)

    @decay.setter
    def decay(self, float value):
        """Set the feedback decay."""
        if not self._initialized:
            raise MinimaError("Delay not initialized")
        lib.ma_delay_set_decay(&self._delay, value)

    def process(self, bytes data) -> bytes:
        """Process audio data through the delay."""
        if not self._initialized:
            raise MinimaError("Delay not initialized")

        cdef lib.ma_uint64 frame_count = len(data) // (self._channels * sizeof(float))
        cdef size_t data_len = len(data)
        cdef const char* input_ptr = <const char*>data
        cdef float* output = <float*>malloc(data_len)

        if output == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_delay_process_pcm_frames(&self._delay, output, <float*>input_ptr, <lib.ma_uint32>frame_count)
            return bytes((<char*>output)[:data_len])
        finally:
            free(output)


# -----------------------------------------------------------------------------
# Ring Buffers
# -----------------------------------------------------------------------------

cdef class RingBuffer:
    """
    Lock-free ring buffer for audio data.

    Useful for producer-consumer scenarios like audio callbacks.

    Example:
        rb = RingBuffer(buffer_size=4096)
        rb.write(data)
        output = rb.read(1024)
    """
    cdef lib.ma_rb _rb
    cdef bint _initialized

    def __cinit__(self):
        self._initialized = False

    def __init__(self, size_t buffer_size):
        """
        Initialize a ring buffer.

        Args:
            buffer_size: Size of the buffer in bytes
        """
        cdef lib.ma_result result

        result = lib.ma_rb_init(buffer_size, NULL, NULL, &self._rb)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize ring buffer (error {result})")

        self._initialized = True

    def __dealloc__(self):
        if self._initialized:
            lib.ma_rb_uninit(&self._rb)
            self._initialized = False

    def reset(self):
        """Reset the ring buffer to empty state."""
        if not self._initialized:
            raise MinimaError("Ring buffer not initialized")
        lib.ma_rb_reset(&self._rb)

    @property
    def available_read(self) -> int:
        """Get the number of bytes available for reading."""
        if not self._initialized:
            raise MinimaError("Ring buffer not initialized")
        return lib.ma_rb_available_read(&self._rb)

    @property
    def available_write(self) -> int:
        """Get the number of bytes available for writing."""
        if not self._initialized:
            raise MinimaError("Ring buffer not initialized")
        return lib.ma_rb_available_write(&self._rb)

    def write(self, bytes data) -> int:
        """
        Write data to the ring buffer.

        Args:
            data: Data to write

        Returns:
            Number of bytes actually written
        """
        if not self._initialized:
            raise MinimaError("Ring buffer not initialized")

        cdef void* write_ptr
        cdef size_t write_size = len(data)
        cdef lib.ma_result result

        result = lib.ma_rb_acquire_write(&self._rb, &write_size, &write_ptr)
        if result != lib.MA_SUCCESS:
            return 0

        memcpy(write_ptr, <char*>data, write_size)
        result = lib.ma_rb_commit_write(&self._rb, write_size)

        return write_size

    def read(self, size_t size) -> bytes:
        """
        Read data from the ring buffer.

        Args:
            size: Maximum number of bytes to read

        Returns:
            Data read from the buffer
        """
        if not self._initialized:
            raise MinimaError("Ring buffer not initialized")

        cdef void* read_ptr
        cdef size_t read_size = size
        cdef lib.ma_result result

        result = lib.ma_rb_acquire_read(&self._rb, &read_size, &read_ptr)
        if result != lib.MA_SUCCESS or read_size == 0:
            return b''

        cdef bytes data = bytes((<char*>read_ptr)[:read_size])
        result = lib.ma_rb_commit_read(&self._rb, read_size)

        return data


cdef class PCMRingBuffer:
    """
    Lock-free ring buffer for PCM audio frames.

    Similar to RingBuffer but works with PCM frames instead of raw bytes.

    Example:
        rb = PCMRingBuffer(frame_capacity=1024, channels=2)
        rb.write_frames(data)
        output = rb.read_frames(256)
    """
    cdef lib.ma_pcm_rb _rb
    cdef bint _initialized
    cdef lib.ma_uint32 _channels
    cdef int _bytes_per_frame

    def __cinit__(self):
        self._initialized = False

    def __init__(self, lib.ma_uint32 frame_capacity, int channels=2,
                 int format=Format.F32, int sample_rate=48000):
        """
        Initialize a PCM ring buffer.

        Args:
            frame_capacity: Capacity in frames
            channels: Number of channels
            format: Sample format
            sample_rate: Sample rate in Hz
        """
        cdef lib.ma_result result

        result = lib.ma_pcm_rb_init(<lib.ma_format>format, channels, frame_capacity, NULL, NULL, &self._rb)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize PCM ring buffer (error {result})")

        self._initialized = True
        self._channels = channels

        # Calculate bytes per frame
        if format == lib.ma_format_u8:
            self._bytes_per_frame = channels * 1
        elif format == lib.ma_format_s16:
            self._bytes_per_frame = channels * 2
        elif format == lib.ma_format_s24:
            self._bytes_per_frame = channels * 3
        elif format == lib.ma_format_s32 or format == lib.ma_format_f32:
            self._bytes_per_frame = channels * 4
        else:
            self._bytes_per_frame = channels * 4

    def __dealloc__(self):
        if self._initialized:
            lib.ma_pcm_rb_uninit(&self._rb)
            self._initialized = False

    def reset(self):
        """Reset the ring buffer to empty state."""
        if not self._initialized:
            raise MinimaError("PCM ring buffer not initialized")
        lib.ma_pcm_rb_reset(&self._rb)

    @property
    def available_read(self) -> int:
        """Get the number of frames available for reading."""
        if not self._initialized:
            raise MinimaError("PCM ring buffer not initialized")
        return lib.ma_pcm_rb_available_read(&self._rb)

    @property
    def available_write(self) -> int:
        """Get the number of frames available for writing."""
        if not self._initialized:
            raise MinimaError("PCM ring buffer not initialized")
        return lib.ma_pcm_rb_available_write(&self._rb)

    def write_frames(self, bytes data) -> int:
        """
        Write PCM frames to the ring buffer.

        Args:
            data: PCM data to write

        Returns:
            Number of frames actually written
        """
        if not self._initialized:
            raise MinimaError("PCM ring buffer not initialized")

        cdef void* write_ptr
        cdef lib.ma_uint32 frame_count = len(data) // self._bytes_per_frame
        cdef lib.ma_result result

        result = lib.ma_pcm_rb_acquire_write(&self._rb, &frame_count, &write_ptr)
        if result != lib.MA_SUCCESS:
            return 0

        memcpy(write_ptr, <char*>data, frame_count * self._bytes_per_frame)
        result = lib.ma_pcm_rb_commit_write(&self._rb, frame_count)

        return frame_count

    def read_frames(self, lib.ma_uint32 frame_count) -> bytes:
        """
        Read PCM frames from the ring buffer.

        Args:
            frame_count: Maximum number of frames to read

        Returns:
            PCM data read from the buffer
        """
        if not self._initialized:
            raise MinimaError("PCM ring buffer not initialized")

        cdef void* read_ptr
        cdef lib.ma_uint32 frames_to_read = frame_count
        cdef lib.ma_result result

        result = lib.ma_pcm_rb_acquire_read(&self._rb, &frames_to_read, &read_ptr)
        if result != lib.MA_SUCCESS or frames_to_read == 0:
            return b''

        cdef bytes data = bytes((<char*>read_ptr)[:frames_to_read * self._bytes_per_frame])
        result = lib.ma_pcm_rb_commit_read(&self._rb, frames_to_read)

        return data


# -----------------------------------------------------------------------------
# Encoder (Recording)
# -----------------------------------------------------------------------------

class EncodingFormat(IntEnum):
    """Audio encoding format for the Encoder."""
    UNKNOWN = 0
    WAV = 1


cdef class Encoder:
    """
    Audio file encoder for recording.

    Example:
        encoder = Encoder("output.wav", channels=2, sample_rate=48000)
        encoder.write(pcm_data)
        encoder.close()
    """
    cdef lib.ma_encoder _encoder
    cdef bint _initialized
    cdef str _path
    cdef lib.ma_uint32 _channels
    cdef int _bytes_per_frame

    def __cinit__(self):
        self._initialized = False

    def __init__(self, str path, int format=Format.F32,
                 int channels=2, int sample_rate=48000,
                 int encoding_format=EncodingFormat.WAV):
        """
        Open a file for encoding.

        Args:
            path: Output file path
            format: Sample format
            channels: Number of channels
            sample_rate: Sample rate in Hz
            encoding_format: Encoding format (WAV)
        """
        cdef lib.ma_encoder_config config
        cdef lib.ma_result result
        cdef bytes path_bytes = path.encode('utf-8')

        config = lib.ma_encoder_config_init(
            <lib.ma_encoding_format>encoding_format,
            <lib.ma_format>format,
            channels,
            sample_rate
        )

        result = lib.ma_encoder_init_file(path_bytes, &config, &self._encoder)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to open '{path}' for encoding (error {result})")

        self._initialized = True
        self._path = path
        self._channels = channels

        # Calculate bytes per frame
        if format == lib.ma_format_u8:
            self._bytes_per_frame = channels * 1
        elif format == lib.ma_format_s16:
            self._bytes_per_frame = channels * 2
        elif format == lib.ma_format_s24:
            self._bytes_per_frame = channels * 3
        elif format == lib.ma_format_s32 or format == lib.ma_format_f32:
            self._bytes_per_frame = channels * 4
        else:
            self._bytes_per_frame = channels * 4

    def __dealloc__(self):
        if self._initialized:
            lib.ma_encoder_uninit(&self._encoder)
            self._initialized = False

    def close(self):
        """Close the encoder and finalize the file."""
        if self._initialized:
            lib.ma_encoder_uninit(&self._encoder)
            self._initialized = False

    @property
    def path(self) -> str:
        """Get the output file path."""
        return self._path

    def write(self, bytes data) -> int:
        """
        Write PCM frames to the encoder.

        Args:
            data: PCM data to encode

        Returns:
            Number of frames written
        """
        if not self._initialized:
            raise MinimaError("Encoder not initialized")

        cdef lib.ma_uint64 frame_count = len(data) // self._bytes_per_frame
        cdef lib.ma_uint64 frames_written
        cdef lib.ma_result result
        cdef const char* data_ptr = <const char*>data

        with nogil:
            result = lib.ma_encoder_write_pcm_frames(&self._encoder, <void*>data_ptr, frame_count, &frames_written)
        _check_result(result)

        return frames_written

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
        return False

    def __repr__(self):
        return f"Encoder({self._path!r})"


# -----------------------------------------------------------------------------
# Node Graph
# -----------------------------------------------------------------------------

class NodeState(IntEnum):
    """State of a node in the audio graph."""
    STARTED = lib.ma_node_state_started
    STOPPED = lib.ma_node_state_stopped


cdef class NodeGraph:
    """
    Audio processing node graph for custom mixing and effects chains.

    The NodeGraph allows building custom audio processing pipelines by
    connecting nodes together. Audio flows from source nodes through
    processing nodes to the endpoint.

    Example:
        graph = NodeGraph(channels=2)
        # Create nodes and connect them
        splitter = SplitterNode(graph, channels=2)
        lpf = LPFNode(graph, cutoff=1000.0)
        # Connect: splitter -> lpf -> endpoint
        splitter.attach_output(0, lpf, 0)
        lpf.attach_output(0, graph.endpoint, 0)
    """
    cdef lib.ma_node_graph _graph
    cdef bint _initialized
    cdef lib.ma_uint32 _channels

    def __cinit__(self):
        self._initialized = False

    def __init__(self, int channels=2):
        """
        Initialize a node graph.

        Args:
            channels: Number of output channels
        """
        cdef lib.ma_node_graph_config config
        cdef lib.ma_result result

        config = lib.ma_node_graph_config_init(channels)

        result = lib.ma_node_graph_init(&config, NULL, &self._graph)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize node graph (error {result})")

        self._initialized = True
        self._channels = channels

    def __dealloc__(self):
        if self._initialized:
            lib.ma_node_graph_uninit(&self._graph, NULL)
            self._initialized = False

    def close(self):
        """Close the node graph and release resources."""
        if self._initialized:
            lib.ma_node_graph_uninit(&self._graph, NULL)
            self._initialized = False

    @property
    def channels(self) -> int:
        """Get the number of channels."""
        if not self._initialized:
            raise MinimaError("Node graph not initialized")
        return lib.ma_node_graph_get_channels(&self._graph)

    @property
    def time(self) -> int:
        """Get the current time in PCM frames."""
        if not self._initialized:
            raise MinimaError("Node graph not initialized")
        return lib.ma_node_graph_get_time(&self._graph)

    @time.setter
    def time(self, lib.ma_uint64 value):
        """Set the current time in PCM frames."""
        if not self._initialized:
            raise MinimaError("Node graph not initialized")
        lib.ma_node_graph_set_time(&self._graph, value)

    def read(self, lib.ma_uint64 frame_count) -> bytes:
        """
        Read processed audio from the node graph.

        Args:
            frame_count: Number of frames to read

        Returns:
            Processed PCM data (float32)
        """
        if not self._initialized:
            raise MinimaError("Node graph not initialized")

        cdef lib.ma_uint64 frames_read
        cdef size_t buffer_size = frame_count * self._channels * sizeof(float)
        cdef float* buffer = <float*>malloc(buffer_size)

        if buffer == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_node_graph_read_pcm_frames(&self._graph, buffer, frame_count, &frames_read)
            return bytes((<char*>buffer)[:frames_read * self._channels * sizeof(float)])
        finally:
            free(buffer)

    cdef lib.ma_node* _get_endpoint(self):
        """Get the endpoint node (internal use)."""
        return lib.ma_node_graph_get_endpoint(&self._graph)

    cdef lib.ma_node_graph* _get_graph(self):
        """Get the internal graph pointer (internal use)."""
        return &self._graph

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
        return False


cdef class SplitterNode:
    """
    Node that splits audio to multiple outputs.

    Useful for routing the same audio to multiple processing chains.

    Example:
        splitter = SplitterNode(graph, channels=2, output_count=2)
        splitter.attach_output(0, effect1, 0)
        splitter.attach_output(1, effect2, 0)
    """
    cdef lib.ma_splitter_node _node
    cdef bint _initialized
    cdef NodeGraph _graph

    def __cinit__(self):
        self._initialized = False
        self._graph = None

    def __init__(self, NodeGraph graph not None, int channels=2, int output_bus_count=2):
        """
        Initialize a splitter node.

        Args:
            graph: The NodeGraph to add this node to
            channels: Number of channels
            output_bus_count: Number of output buses
        """
        if not graph._initialized:
            raise MinimaError("Node graph not initialized")

        cdef lib.ma_splitter_node_config config
        cdef lib.ma_result result

        config = lib.ma_splitter_node_config_init(channels)
        config.outputBusCount = output_bus_count

        result = lib.ma_splitter_node_init(graph._get_graph(), &config, NULL, &self._node)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize splitter node (error {result})")

        self._initialized = True
        self._graph = graph

    def __dealloc__(self):
        if self._initialized:
            lib.ma_splitter_node_uninit(&self._node, NULL)
            self._initialized = False

    def attach_output(self, int output_bus, object target_node, int target_input_bus):
        """
        Attach an output bus to another node's input.

        Args:
            output_bus: Output bus index on this node
            target_node: Target node to connect to
            target_input_bus: Input bus index on the target node
        """
        if not self._initialized:
            raise MinimaError("Splitter node not initialized")

        cdef lib.ma_node* target
        if isinstance(target_node, SplitterNode):
            target = <lib.ma_node*>&(<SplitterNode>target_node)._node
        elif isinstance(target_node, LPFNode):
            target = <lib.ma_node*>&(<LPFNode>target_node)._node
        elif isinstance(target_node, HPFNode):
            target = <lib.ma_node*>&(<HPFNode>target_node)._node
        elif isinstance(target_node, BPFNode):
            target = <lib.ma_node*>&(<BPFNode>target_node)._node
        elif isinstance(target_node, DelayNode):
            target = <lib.ma_node*>&(<DelayNode>target_node)._node
        else:
            raise TypeError("Unsupported target node type")

        cdef lib.ma_result result = lib.ma_node_attach_output_bus(
            <lib.ma_node*>&self._node, output_bus, target, target_input_bus
        )
        _check_result(result)

    def detach_output(self, int output_bus):
        """Detach an output bus."""
        if not self._initialized:
            raise MinimaError("Splitter node not initialized")
        cdef lib.ma_result result = lib.ma_node_detach_output_bus(<lib.ma_node*>&self._node, output_bus)
        _check_result(result)

    def detach_all_outputs(self):
        """Detach all output buses."""
        if not self._initialized:
            raise MinimaError("Splitter node not initialized")
        cdef lib.ma_result result = lib.ma_node_detach_all_output_buses(<lib.ma_node*>&self._node)
        _check_result(result)

    @property
    def state(self) -> int:
        """Get the node state."""
        if not self._initialized:
            raise MinimaError("Splitter node not initialized")
        return lib.ma_node_get_state(<lib.ma_node*>&self._node)

    @state.setter
    def state(self, int value):
        """Set the node state."""
        if not self._initialized:
            raise MinimaError("Splitter node not initialized")
        lib.ma_node_set_state(<lib.ma_node*>&self._node, <lib.ma_node_state>value)

    def set_output_volume(self, int output_bus, float volume):
        """Set the volume of an output bus."""
        if not self._initialized:
            raise MinimaError("Splitter node not initialized")
        lib.ma_node_set_output_bus_volume(<lib.ma_node*>&self._node, output_bus, volume)

    def get_output_volume(self, int output_bus) -> float:
        """Get the volume of an output bus."""
        if not self._initialized:
            raise MinimaError("Splitter node not initialized")
        return lib.ma_node_get_output_bus_volume(<lib.ma_node*>&self._node, output_bus)


cdef class LPFNode:
    """
    Low-pass filter node for the node graph.

    Example:
        lpf = LPFNode(graph, cutoff=1000.0, order=2)
        source.attach_output(0, lpf, 0)
        lpf.attach_output(0, graph.endpoint, 0)
    """
    cdef lib.ma_lpf_node _node
    cdef bint _initialized
    cdef NodeGraph _graph
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False
        self._graph = None

    def __init__(self, NodeGraph graph not None, double cutoff=1000.0, int order=2,
                 int channels=2, int sample_rate=48000):
        """
        Initialize a low-pass filter node.

        Args:
            graph: The NodeGraph to add this node to
            cutoff: Cutoff frequency in Hz
            order: Filter order (1-8)
            channels: Number of channels
            sample_rate: Sample rate in Hz
        """
        if not graph._initialized:
            raise MinimaError("Node graph not initialized")

        cdef lib.ma_lpf_node_config config
        cdef lib.ma_result result

        config = lib.ma_lpf_node_config_init(channels, sample_rate, cutoff, order)

        result = lib.ma_lpf_node_init(graph._get_graph(), &config, NULL, &self._node)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize LPF node (error {result})")

        self._initialized = True
        self._graph = graph
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_lpf_node_uninit(&self._node, NULL)
            self._initialized = False

    def reinit(self, double cutoff, int order=2):
        """Reinitialize with new parameters."""
        if not self._initialized:
            raise MinimaError("LPF node not initialized")
        cdef lib.ma_lpf_config config = lib.ma_lpf_config_init(
            lib.ma_format_f32, self._channels, self._sample_rate, cutoff, order
        )
        cdef lib.ma_result result = lib.ma_lpf_node_reinit(&config, &self._node)
        _check_result(result)

    def attach_output(self, int output_bus, object target_node, int target_input_bus):
        """Attach output to another node."""
        if not self._initialized:
            raise MinimaError("LPF node not initialized")

        cdef lib.ma_node* target
        if isinstance(target_node, SplitterNode):
            target = <lib.ma_node*>&(<SplitterNode>target_node)._node
        elif isinstance(target_node, LPFNode):
            target = <lib.ma_node*>&(<LPFNode>target_node)._node
        elif isinstance(target_node, HPFNode):
            target = <lib.ma_node*>&(<HPFNode>target_node)._node
        elif isinstance(target_node, BPFNode):
            target = <lib.ma_node*>&(<BPFNode>target_node)._node
        elif isinstance(target_node, DelayNode):
            target = <lib.ma_node*>&(<DelayNode>target_node)._node
        else:
            raise TypeError("Unsupported target node type")

        cdef lib.ma_result result = lib.ma_node_attach_output_bus(
            <lib.ma_node*>&self._node, output_bus, target, target_input_bus
        )
        _check_result(result)

    def detach_output(self, int output_bus):
        """Detach an output bus."""
        if not self._initialized:
            raise MinimaError("LPF node not initialized")
        lib.ma_node_detach_output_bus(<lib.ma_node*>&self._node, output_bus)

    @property
    def state(self) -> int:
        """Get the node state."""
        if not self._initialized:
            raise MinimaError("LPF node not initialized")
        return lib.ma_node_get_state(<lib.ma_node*>&self._node)

    @state.setter
    def state(self, int value):
        """Set the node state."""
        if not self._initialized:
            raise MinimaError("LPF node not initialized")
        lib.ma_node_set_state(<lib.ma_node*>&self._node, <lib.ma_node_state>value)


cdef class HPFNode:
    """
    High-pass filter node for the node graph.

    Example:
        hpf = HPFNode(graph, cutoff=200.0, order=2)
    """
    cdef lib.ma_hpf_node _node
    cdef bint _initialized
    cdef NodeGraph _graph
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False
        self._graph = None

    def __init__(self, NodeGraph graph not None, double cutoff=200.0, int order=2,
                 int channels=2, int sample_rate=48000):
        """
        Initialize a high-pass filter node.

        Args:
            graph: The NodeGraph to add this node to
            cutoff: Cutoff frequency in Hz
            order: Filter order (1-8)
            channels: Number of channels
            sample_rate: Sample rate in Hz
        """
        if not graph._initialized:
            raise MinimaError("Node graph not initialized")

        cdef lib.ma_hpf_node_config config
        cdef lib.ma_result result

        config = lib.ma_hpf_node_config_init(channels, sample_rate, cutoff, order)

        result = lib.ma_hpf_node_init(graph._get_graph(), &config, NULL, &self._node)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize HPF node (error {result})")

        self._initialized = True
        self._graph = graph
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_hpf_node_uninit(&self._node, NULL)
            self._initialized = False

    def reinit(self, double cutoff, int order=2):
        """Reinitialize with new parameters."""
        if not self._initialized:
            raise MinimaError("HPF node not initialized")
        cdef lib.ma_hpf_config config = lib.ma_hpf_config_init(
            lib.ma_format_f32, self._channels, self._sample_rate, cutoff, order
        )
        cdef lib.ma_result result = lib.ma_hpf_node_reinit(&config, &self._node)
        _check_result(result)

    def attach_output(self, int output_bus, object target_node, int target_input_bus):
        """Attach output to another node."""
        if not self._initialized:
            raise MinimaError("HPF node not initialized")

        cdef lib.ma_node* target
        if isinstance(target_node, SplitterNode):
            target = <lib.ma_node*>&(<SplitterNode>target_node)._node
        elif isinstance(target_node, LPFNode):
            target = <lib.ma_node*>&(<LPFNode>target_node)._node
        elif isinstance(target_node, HPFNode):
            target = <lib.ma_node*>&(<HPFNode>target_node)._node
        elif isinstance(target_node, BPFNode):
            target = <lib.ma_node*>&(<BPFNode>target_node)._node
        elif isinstance(target_node, DelayNode):
            target = <lib.ma_node*>&(<DelayNode>target_node)._node
        else:
            raise TypeError("Unsupported target node type")

        cdef lib.ma_result result = lib.ma_node_attach_output_bus(
            <lib.ma_node*>&self._node, output_bus, target, target_input_bus
        )
        _check_result(result)

    def detach_output(self, int output_bus):
        """Detach an output bus."""
        if not self._initialized:
            raise MinimaError("HPF node not initialized")
        lib.ma_node_detach_output_bus(<lib.ma_node*>&self._node, output_bus)

    @property
    def state(self) -> int:
        """Get the node state."""
        if not self._initialized:
            raise MinimaError("HPF node not initialized")
        return lib.ma_node_get_state(<lib.ma_node*>&self._node)

    @state.setter
    def state(self, int value):
        """Set the node state."""
        if not self._initialized:
            raise MinimaError("HPF node not initialized")
        lib.ma_node_set_state(<lib.ma_node*>&self._node, <lib.ma_node_state>value)


cdef class BPFNode:
    """
    Band-pass filter node for the node graph.

    Example:
        bpf = BPFNode(graph, cutoff=1000.0, order=2)
    """
    cdef lib.ma_bpf_node _node
    cdef bint _initialized
    cdef NodeGraph _graph
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False
        self._graph = None

    def __init__(self, NodeGraph graph not None, double cutoff=1000.0, int order=2,
                 int channels=2, int sample_rate=48000):
        """
        Initialize a band-pass filter node.

        Args:
            graph: The NodeGraph to add this node to
            cutoff: Center frequency in Hz
            order: Filter order (must be even, 2-8)
            channels: Number of channels
            sample_rate: Sample rate in Hz
        """
        if not graph._initialized:
            raise MinimaError("Node graph not initialized")

        cdef lib.ma_bpf_node_config config
        cdef lib.ma_result result

        config = lib.ma_bpf_node_config_init(channels, sample_rate, cutoff, order)

        result = lib.ma_bpf_node_init(graph._get_graph(), &config, NULL, &self._node)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize BPF node (error {result})")

        self._initialized = True
        self._graph = graph
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_bpf_node_uninit(&self._node, NULL)
            self._initialized = False

    def reinit(self, double cutoff, int order=2):
        """Reinitialize with new parameters."""
        if not self._initialized:
            raise MinimaError("BPF node not initialized")
        cdef lib.ma_bpf_config config = lib.ma_bpf_config_init(
            lib.ma_format_f32, self._channels, self._sample_rate, cutoff, order
        )
        cdef lib.ma_result result = lib.ma_bpf_node_reinit(&config, &self._node)
        _check_result(result)

    def attach_output(self, int output_bus, object target_node, int target_input_bus):
        """Attach output to another node."""
        if not self._initialized:
            raise MinimaError("BPF node not initialized")

        cdef lib.ma_node* target
        if isinstance(target_node, SplitterNode):
            target = <lib.ma_node*>&(<SplitterNode>target_node)._node
        elif isinstance(target_node, LPFNode):
            target = <lib.ma_node*>&(<LPFNode>target_node)._node
        elif isinstance(target_node, HPFNode):
            target = <lib.ma_node*>&(<HPFNode>target_node)._node
        elif isinstance(target_node, BPFNode):
            target = <lib.ma_node*>&(<BPFNode>target_node)._node
        elif isinstance(target_node, DelayNode):
            target = <lib.ma_node*>&(<DelayNode>target_node)._node
        else:
            raise TypeError("Unsupported target node type")

        cdef lib.ma_result result = lib.ma_node_attach_output_bus(
            <lib.ma_node*>&self._node, output_bus, target, target_input_bus
        )
        _check_result(result)

    def detach_output(self, int output_bus):
        """Detach an output bus."""
        if not self._initialized:
            raise MinimaError("BPF node not initialized")
        lib.ma_node_detach_output_bus(<lib.ma_node*>&self._node, output_bus)

    @property
    def state(self) -> int:
        """Get the node state."""
        if not self._initialized:
            raise MinimaError("BPF node not initialized")
        return lib.ma_node_get_state(<lib.ma_node*>&self._node)

    @state.setter
    def state(self, int value):
        """Set the node state."""
        if not self._initialized:
            raise MinimaError("BPF node not initialized")
        lib.ma_node_set_state(<lib.ma_node*>&self._node, <lib.ma_node_state>value)


cdef class DelayNode:
    """
    Delay effect node for the node graph.

    Example:
        delay = DelayNode(graph, delay_ms=250.0, decay=0.5)
    """
    cdef lib.ma_delay_node _node
    cdef bint _initialized
    cdef NodeGraph _graph
    cdef lib.ma_uint32 _channels
    cdef lib.ma_uint32 _sample_rate

    def __cinit__(self):
        self._initialized = False
        self._graph = None

    def __init__(self, NodeGraph graph not None, double delay_ms=250.0, float decay=0.5,
                 int channels=2, int sample_rate=48000):
        """
        Initialize a delay node.

        Args:
            graph: The NodeGraph to add this node to
            delay_ms: Delay time in milliseconds
            decay: Feedback decay (0.0 to 1.0)
            channels: Number of channels
            sample_rate: Sample rate in Hz
        """
        if not graph._initialized:
            raise MinimaError("Node graph not initialized")

        cdef lib.ma_delay_node_config config
        cdef lib.ma_result result
        cdef lib.ma_uint32 delay_frames = <lib.ma_uint32>(delay_ms * sample_rate / 1000.0)

        config = lib.ma_delay_node_config_init(channels, sample_rate, delay_frames, decay)

        result = lib.ma_delay_node_init(graph._get_graph(), &config, NULL, &self._node)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize delay node (error {result})")

        self._initialized = True
        self._graph = graph
        self._channels = channels
        self._sample_rate = sample_rate

    def __dealloc__(self):
        if self._initialized:
            lib.ma_delay_node_uninit(&self._node, NULL)
            self._initialized = False

    @property
    def wet(self) -> float:
        """Get the wet signal level."""
        if not self._initialized:
            raise MinimaError("Delay node not initialized")
        return lib.ma_delay_node_get_wet(&self._node)

    @wet.setter
    def wet(self, float value):
        """Set the wet signal level."""
        if not self._initialized:
            raise MinimaError("Delay node not initialized")
        lib.ma_delay_node_set_wet(&self._node, value)

    @property
    def dry(self) -> float:
        """Get the dry signal level."""
        if not self._initialized:
            raise MinimaError("Delay node not initialized")
        return lib.ma_delay_node_get_dry(&self._node)

    @dry.setter
    def dry(self, float value):
        """Set the dry signal level."""
        if not self._initialized:
            raise MinimaError("Delay node not initialized")
        lib.ma_delay_node_set_dry(&self._node, value)

    @property
    def decay(self) -> float:
        """Get the feedback decay."""
        if not self._initialized:
            raise MinimaError("Delay node not initialized")
        return lib.ma_delay_node_get_decay(&self._node)

    @decay.setter
    def decay(self, float value):
        """Set the feedback decay."""
        if not self._initialized:
            raise MinimaError("Delay node not initialized")
        lib.ma_delay_node_set_decay(&self._node, value)

    def attach_output(self, int output_bus, object target_node, int target_input_bus):
        """Attach output to another node."""
        if not self._initialized:
            raise MinimaError("Delay node not initialized")

        cdef lib.ma_node* target
        if isinstance(target_node, SplitterNode):
            target = <lib.ma_node*>&(<SplitterNode>target_node)._node
        elif isinstance(target_node, LPFNode):
            target = <lib.ma_node*>&(<LPFNode>target_node)._node
        elif isinstance(target_node, HPFNode):
            target = <lib.ma_node*>&(<HPFNode>target_node)._node
        elif isinstance(target_node, BPFNode):
            target = <lib.ma_node*>&(<BPFNode>target_node)._node
        elif isinstance(target_node, DelayNode):
            target = <lib.ma_node*>&(<DelayNode>target_node)._node
        else:
            raise TypeError("Unsupported target node type")

        cdef lib.ma_result result = lib.ma_node_attach_output_bus(
            <lib.ma_node*>&self._node, output_bus, target, target_input_bus
        )
        _check_result(result)

    def detach_output(self, int output_bus):
        """Detach an output bus."""
        if not self._initialized:
            raise MinimaError("Delay node not initialized")
        lib.ma_node_detach_output_bus(<lib.ma_node*>&self._node, output_bus)

    @property
    def state(self) -> int:
        """Get the node state."""
        if not self._initialized:
            raise MinimaError("Delay node not initialized")
        return lib.ma_node_get_state(<lib.ma_node*>&self._node)

    @state.setter
    def state(self, int value):
        """Set the node state."""
        if not self._initialized:
            raise MinimaError("Delay node not initialized")
        lib.ma_node_set_state(<lib.ma_node*>&self._node, <lib.ma_node_state>value)


# -----------------------------------------------------------------------------
# Resource Manager
# -----------------------------------------------------------------------------

# Resource manager flags
RESOURCE_MANAGER_FLAG_NON_BLOCKING = lib.MA_RESOURCE_MANAGER_FLAG_NON_BLOCKING
RESOURCE_MANAGER_DATA_SOURCE_FLAG_STREAM = lib.MA_RESOURCE_MANAGER_DATA_SOURCE_FLAG_STREAM
RESOURCE_MANAGER_DATA_SOURCE_FLAG_DECODE = lib.MA_RESOURCE_MANAGER_DATA_SOURCE_FLAG_DECODE
RESOURCE_MANAGER_DATA_SOURCE_FLAG_ASYNC = lib.MA_RESOURCE_MANAGER_DATA_SOURCE_FLAG_ASYNC
RESOURCE_MANAGER_DATA_SOURCE_FLAG_WAIT_INIT = lib.MA_RESOURCE_MANAGER_DATA_SOURCE_FLAG_WAIT_INIT


cdef class ResourceManager:
    """
    Manages audio resource loading with optional async support.

    The ResourceManager handles loading and caching of audio files,
    with support for asynchronous loading and streaming.

    Example:
        rm = ResourceManager()
        source = rm.load("music.mp3", stream=True)
        # Use the source...
        source.close()
        rm.close()
    """
    cdef lib.ma_resource_manager _rm
    cdef bint _initialized

    def __cinit__(self):
        self._initialized = False

    def __init__(self, int decoded_format=Format.F32,
                 int decoded_channels=0, int decoded_sample_rate=0,
                 int job_thread_count=1):
        """
        Initialize a resource manager.

        Args:
            decoded_format: Format for decoded audio (default: F32)
            decoded_channels: Channels for decoded audio (0 = native)
            decoded_sample_rate: Sample rate for decoded audio (0 = native)
            job_thread_count: Number of job threads for async loading
        """
        cdef lib.ma_resource_manager_config config
        cdef lib.ma_result result

        config = lib.ma_resource_manager_config_init()
        config.decodedFormat = <lib.ma_format>decoded_format
        config.decodedChannels = decoded_channels
        config.decodedSampleRate = decoded_sample_rate
        config.jobThreadCount = job_thread_count

        result = lib.ma_resource_manager_init(&config, &self._rm)
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to initialize resource manager (error {result})")

        self._initialized = True

    def __dealloc__(self):
        if self._initialized:
            lib.ma_resource_manager_uninit(&self._rm)
            self._initialized = False

    def close(self):
        """Close the resource manager and release resources."""
        if self._initialized:
            lib.ma_resource_manager_uninit(&self._rm)
            self._initialized = False

    def load(self, str path, bint stream=False, bint decode=True,
             bint async_load=False, bint wait_init=True) -> "ResourceDataSource":
        """
        Load an audio file as a data source.

        Args:
            path: Path to the audio file
            stream: Stream from disk instead of loading to memory
            decode: Decode to PCM (required for most uses)
            async_load: Load asynchronously
            wait_init: Wait for initialization to complete (if async)

        Returns:
            ResourceDataSource for the loaded audio
        """
        if not self._initialized:
            raise MinimaError("Resource manager not initialized")

        cdef lib.ma_uint32 flags = 0
        if stream:
            flags |= lib.MA_RESOURCE_MANAGER_DATA_SOURCE_FLAG_STREAM
        if decode:
            flags |= lib.MA_RESOURCE_MANAGER_DATA_SOURCE_FLAG_DECODE
        if async_load:
            flags |= lib.MA_RESOURCE_MANAGER_DATA_SOURCE_FLAG_ASYNC
        if wait_init:
            flags |= lib.MA_RESOURCE_MANAGER_DATA_SOURCE_FLAG_WAIT_INIT

        return ResourceDataSource(self, path, flags)

    def register_file(self, str path, bint stream=False, bint decode=True):
        """
        Pre-register a file for later loading.

        Args:
            path: Path to the audio file
            stream: Stream from disk
            decode: Decode to PCM
        """
        if not self._initialized:
            raise MinimaError("Resource manager not initialized")

        cdef lib.ma_uint32 flags = 0
        if stream:
            flags |= lib.MA_RESOURCE_MANAGER_DATA_SOURCE_FLAG_STREAM
        if decode:
            flags |= lib.MA_RESOURCE_MANAGER_DATA_SOURCE_FLAG_DECODE

        cdef bytes path_bytes = path.encode('utf-8')
        cdef lib.ma_result result = lib.ma_resource_manager_register_file(&self._rm, path_bytes, flags)
        _check_result(result)

    def unregister_file(self, str path):
        """Unregister a previously registered file."""
        if not self._initialized:
            raise MinimaError("Resource manager not initialized")

        cdef bytes path_bytes = path.encode('utf-8')
        cdef lib.ma_result result = lib.ma_resource_manager_unregister_file(&self._rm, path_bytes)
        _check_result(result)

    cdef lib.ma_resource_manager* _get_rm(self):
        """Get the internal resource manager pointer."""
        return &self._rm

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
        return False


cdef class ResourceDataSource:
    """
    Audio data source loaded through the ResourceManager.

    Provides access to loaded or streamed audio data.

    Example:
        rm = ResourceManager()
        source = rm.load("music.mp3")
        data = source.read(1024)
        print(f"Length: {source.length} frames")
    """
    cdef lib.ma_resource_manager_data_source _source
    cdef bint _initialized
    cdef ResourceManager _rm
    cdef str _path

    def __cinit__(self):
        self._initialized = False
        self._rm = None

    def __init__(self, ResourceManager rm not None, str path, lib.ma_uint32 flags):
        """
        Initialize a resource data source (internal use - use ResourceManager.load()).
        """
        if not rm._initialized:
            raise MinimaError("Resource manager not initialized")

        cdef bytes path_bytes = path.encode('utf-8')
        cdef lib.ma_result result

        result = lib.ma_resource_manager_data_source_init(
            rm._get_rm(), path_bytes, flags, NULL, &self._source
        )
        if result != lib.MA_SUCCESS:
            raise MinimaError(f"Failed to load '{path}' (error {result})")

        self._initialized = True
        self._rm = rm
        self._path = path

    def __dealloc__(self):
        if self._initialized:
            lib.ma_resource_manager_data_source_uninit(&self._source)
            self._initialized = False

    def close(self):
        """Close the data source and release resources."""
        if self._initialized:
            lib.ma_resource_manager_data_source_uninit(&self._source)
            self._initialized = False

    @property
    def path(self) -> str:
        """Get the file path."""
        return self._path

    @property
    def length(self) -> int:
        """Get the total length in PCM frames."""
        if not self._initialized:
            raise MinimaError("Data source not initialized")
        cdef lib.ma_uint64 length
        cdef lib.ma_result result = lib.ma_resource_manager_data_source_get_length_in_pcm_frames(&self._source, &length)
        if result != lib.MA_SUCCESS:
            return 0
        return length

    @property
    def cursor(self) -> int:
        """Get the current position in PCM frames."""
        if not self._initialized:
            raise MinimaError("Data source not initialized")
        cdef lib.ma_uint64 cursor
        cdef lib.ma_result result = lib.ma_resource_manager_data_source_get_cursor_in_pcm_frames(&self._source, &cursor)
        if result != lib.MA_SUCCESS:
            return 0
        return cursor

    @property
    def is_looping(self) -> bool:
        """Check if the source is set to loop."""
        if not self._initialized:
            raise MinimaError("Data source not initialized")
        return bool(lib.ma_resource_manager_data_source_is_looping(&self._source))

    @is_looping.setter
    def is_looping(self, bint value):
        """Set whether the source loops."""
        if not self._initialized:
            raise MinimaError("Data source not initialized")
        lib.ma_resource_manager_data_source_set_looping(&self._source, value)

    def seek(self, lib.ma_uint64 frame):
        """Seek to a specific PCM frame."""
        if not self._initialized:
            raise MinimaError("Data source not initialized")
        cdef lib.ma_result result
        with nogil:
            result = lib.ma_resource_manager_data_source_seek_to_pcm_frame(&self._source, frame)
        _check_result(result)

    def read(self, lib.ma_uint64 frame_count) -> bytes:
        """
        Read PCM frames from the data source.

        Args:
            frame_count: Number of frames to read

        Returns:
            PCM data (float32)
        """
        if not self._initialized:
            raise MinimaError("Data source not initialized")

        # Get format info
        cdef lib.ma_format format_out
        cdef lib.ma_uint32 channels
        cdef lib.ma_uint32 sample_rate
        lib.ma_resource_manager_data_source_get_data_format(&self._source, &format_out, &channels, &sample_rate, NULL, 0)

        cdef int bytes_per_sample
        if format_out == lib.ma_format_u8:
            bytes_per_sample = 1
        elif format_out == lib.ma_format_s16:
            bytes_per_sample = 2
        elif format_out == lib.ma_format_s24:
            bytes_per_sample = 3
        else:
            bytes_per_sample = 4

        cdef lib.ma_uint64 frames_read
        cdef size_t buffer_size = frame_count * channels * bytes_per_sample
        cdef void* buffer = malloc(buffer_size)

        if buffer == NULL:
            raise MemoryError("Failed to allocate buffer")

        try:
            with nogil:
                lib.ma_resource_manager_data_source_read_pcm_frames(&self._source, buffer, frame_count, &frames_read)
            return bytes((<char*>buffer)[:frames_read * channels * bytes_per_sample])
        finally:
            free(buffer)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
        return False

    def __repr__(self):
        return f"ResourceDataSource({self._path!r})"


# -----------------------------------------------------------------------------
# Legacy compatibility functions
# -----------------------------------------------------------------------------

def play_sine(double amp=0.2, double freq=220):
    """
    Play a sine wave (interactive demo function).

    Note: This function blocks waiting for user input. For production use,
    use the Engine and Waveform classes instead.
    """
    cdef lib.ma_waveform sineWave
    cdef lib.ma_device_config deviceConfig
    cdef lib.ma_device device
    cdef lib.ma_waveform_config sineWaveConfig

    sineWaveConfig = lib.ma_waveform_config_init(
        lib.ma_format_f32,
        DEVICE_CHANNELS, DEVICE_SAMPLE_RATE,
        lib.ma_waveform_type_sine, amp, freq)

    lib.ma_waveform_init(&sineWaveConfig, &sineWave)

    deviceConfig = lib.ma_device_config_init(lib.ma_device_type_playback)
    deviceConfig.playback.format   = lib.ma_format_f32
    deviceConfig.playback.channels = DEVICE_CHANNELS
    deviceConfig.sampleRate        = DEVICE_SAMPLE_RATE
    deviceConfig.dataCallback      = _sine_data_callback
    deviceConfig.pUserData         = &sineWave

    if lib.ma_device_init(NULL, &deviceConfig, &device) != lib.MA_SUCCESS:
        print("Failed to open playback device.")
        return -4

    print("Device Name: %s" % device.playback.name.decode())

    if lib.ma_device_start(&device) != lib.MA_SUCCESS:
        print("Failed to start playback device.")
        lib.ma_device_uninit(&device)
        return -5

    if input("Press Enter to quit...\n") == '':
        lib.ma_device_uninit(&device)


cdef void _sine_data_callback(lib.ma_device* device,
                              void* output,
                              const void* input_,
                              lib.ma_uint32 frame_count) noexcept nogil:
    """Callback for play_sine function."""
    cdef lib.ma_waveform* sinewave = <lib.ma_waveform*>device.pUserData
    lib.ma_waveform_read_pcm_frames(sinewave, output, frame_count, NULL)


def play_file(str path):
    """
    Play an audio file (interactive demo function).

    Note: This function blocks waiting for user input. For production use,
    use the Engine class instead.
    """
    cdef lib.ma_result result
    cdef lib.ma_decoder decoder
    cdef lib.ma_device_config deviceConfig
    cdef lib.ma_device device

    result = lib.ma_decoder_init_file(path.encode('utf8'), NULL, &decoder)
    if result != lib.MA_SUCCESS:
        print(f"Failed to open file: {path}")
        return

    deviceConfig = lib.ma_device_config_init(lib.ma_device_type_playback)
    deviceConfig.playback.format   = decoder.outputFormat
    deviceConfig.playback.channels = decoder.outputChannels
    deviceConfig.sampleRate        = decoder.outputSampleRate
    deviceConfig.dataCallback      = _file_data_callback
    deviceConfig.pUserData         = &decoder

    if lib.ma_device_init(NULL, &deviceConfig, &device) != lib.MA_SUCCESS:
        print("Failed to open playback device.")
        lib.ma_decoder_uninit(&decoder)
        return

    if lib.ma_device_start(&device) != lib.MA_SUCCESS:
        print("Failed to start playback device.")
        lib.ma_device_uninit(&device)
        lib.ma_decoder_uninit(&decoder)
        return

    if input("Press Enter to quit...\n") == '':
        lib.ma_device_uninit(&device)
        lib.ma_decoder_uninit(&decoder)


cdef void _file_data_callback(lib.ma_device* device,
                              void* output, const void* input_,
                              lib.ma_uint32 frame_count) noexcept nogil:
    """Callback for play_file function."""
    cdef lib.ma_decoder* decoder = <lib.ma_decoder*>device.pUserData
    if decoder == NULL:
        return
    lib.ma_decoder_read_pcm_frames(decoder, output, frame_count, NULL)


def engine_play_file(str filename):
    """
    Play an audio file using the engine (interactive demo function).

    Note: This function blocks waiting for user input. For production use,
    use the Engine class instead.
    """
    cdef lib.ma_result result
    cdef lib.ma_engine engine

    result = lib.ma_engine_init(NULL, &engine)
    if result != lib.MA_SUCCESS:
        print("Failed to initialize audio engine.")
        return

    lib.ma_engine_play_sound(&engine, filename.encode('utf8'), NULL)

    if input("Press Enter to quit...\n") == '':
        lib.ma_engine_uninit(&engine)
