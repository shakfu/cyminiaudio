
from libc.stddef cimport wchar_t


cdef extern from "<pthread.h>" nogil:
    # see: https://github.com/python-llfuse/python-llfuse/blob/master/Include/pthread.pxd
    ctypedef unsigned long int pthread_t

    ctypedef union pthread_mutex_t:
        pass

    ctypedef union pthread_cond_t:
        pass


cdef extern from "miniaudio.h":
    """
    #define MA_NO_RUNTIME_LINKING
    #define MA_ENABLE_ONLY_SPECIFIC_BACKENDS
    #define MA_ENABLE_COREAUDIO
    #define MINIAUDIO_IMPLEMENTATION
    """

    # DEF MA_SUCCESS = 0

    DEF MA_MAX_CHANNELS = 32


    ctypedef   signed char      ma_int8
    ctypedef unsigned char      ma_uint8
    ctypedef   signed short     ma_int16
    ctypedef unsigned short     ma_uint16
    ctypedef   signed int       ma_int32
    ctypedef unsigned int       ma_uint32
    ctypedef signed long long   ma_int64
    ctypedef unsigned long long ma_uint64

    ctypedef ma_uint64 ma_uintptr
    ctypedef ma_uint8  ma_bool8
    ctypedef ma_uint32 ma_bool32


    # cdef int MA_TRUE = 1
    # cdef int MA_TRUE = 0
    # cdef int MA_SIZE_MAX = 0xFFFFFFFF


    ctypedef float   ma_float
    ctypedef double  ma_double

    ctypedef void* ma_handle
    ctypedef void* ma_ptr
    ctypedef void* ma_proc

# --------------------------------------------------------
# Logging Levels
    
    ctypedef struct ma_context
    ctypedef struct ma_device

    ctypedef ma_uint8 ma_channel

    ctypedef enum ma_result:
        MA_SUCCESS                        =  0
        MA_ERROR                          = -1  # A generic error.
        MA_INVALID_ARGS                   = -2
        MA_INVALID_OPERATION              = -3
        MA_OUT_OF_MEMORY                  = -4
        MA_OUT_OF_RANGE                   = -5
        MA_ACCESS_DENIED                  = -6
        MA_DOES_NOT_EXIST                 = -7
        MA_ALREADY_EXISTS                 = -8
        MA_TOO_MANY_OPEN_FILES            = -9
        MA_INVALID_FILE                   = -10
        MA_TOO_BIG                        = -11
        MA_PATH_TOO_LONG                  = -12
        MA_NAME_TOO_LONG                  = -13
        MA_NOT_DIRECTORY                  = -14
        MA_IS_DIRECTORY                   = -15
        MA_DIRECTORY_NOT_EMPTY            = -16
        MA_AT_END                         = -17
        MA_NO_SPACE                       = -18
        MA_BUSY                           = -19
        MA_IO_ERROR                       = -20
        MA_INTERRUPT                      = -21
        MA_UNAVAILABLE                    = -22
        MA_ALREADY_IN_USE                 = -23
        MA_BAD_ADDRESS                    = -24
        MA_BAD_SEEK                       = -25
        MA_BAD_PIPE                       = -26
        MA_DEADLOCK                       = -27
        MA_TOO_MANY_LINKS                 = -28
        MA_NOT_IMPLEMENTED                = -29
        MA_NO_MESSAGE                     = -30
        MA_BAD_MESSAGE                    = -31
        MA_NO_DATA_AVAILABLE              = -32
        MA_INVALID_DATA                   = -33
        MA_TIMEOUT                        = -34
        MA_NO_NETWORK                     = -35
        MA_NOT_UNIQUE                     = -36
        MA_NOT_SOCKET                     = -37
        MA_NO_ADDRESS                     = -38
        MA_BAD_PROTOCOL                   = -39
        MA_PROTOCOL_UNAVAILABLE           = -40
        MA_PROTOCOL_NOT_SUPPORTED         = -41
        MA_PROTOCOL_FAMILY_NOT_SUPPORTED  = -42
        MA_ADDRESS_FAMILY_NOT_SUPPORTED   = -43
        MA_SOCKET_NOT_SUPPORTED           = -44
        MA_CONNECTION_RESET               = -45
        MA_ALREADY_CONNECTED              = -46
        MA_NOT_CONNECTED                  = -47
        MA_CONNECTION_REFUSED             = -48
        MA_NO_HOST                        = -49
        MA_IN_PROGRESS                    = -50
        MA_CANCELLED                      = -51
        MA_MEMORY_ALREADY_MAPPED          = -52

        # General non-standard errors.
        MA_CRC_MISMATCH                   = -100

        # General miniaudio-specific errors.
        MA_FORMAT_NOT_SUPPORTED           = -200
        MA_DEVICE_TYPE_NOT_SUPPORTED      = -201
        MA_SHARE_MODE_NOT_SUPPORTED       = -202
        MA_NO_BACKEND                     = -203
        MA_NO_DEVICE                      = -204
        MA_API_NOT_FOUND                  = -205
        MA_INVALID_DEVICE_CONFIG          = -206
        MA_LOOP                           = -207
        MA_BACKEND_NOT_ENABLED            = -208

        # State errors.
        MA_DEVICE_NOT_INITIALIZED         = -300
        MA_DEVICE_ALREADY_INITIALIZED     = -301
        MA_DEVICE_NOT_STARTED             = -302
        MA_DEVICE_NOT_STOPPED             = -303

        # Operation errors.
        MA_FAILED_TO_INIT_BACKEND         = -400
        MA_FAILED_TO_OPEN_BACKEND_DEVICE  = -401
        MA_FAILED_TO_START_BACKEND_DEVICE = -402
        MA_FAILED_TO_STOP_BACKEND_DEVICE  = -403


    ctypedef enum ma_stream_format:
        ma_stream_format_pcm = 0

    ctypedef enum ma_stream_layout:
        ma_stream_layout_interleaved   = 0
        ma_stream_layout_deinterleaved = 1

    ctypedef enum ma_dither_mode: 
        ma_dither_mode_none      = 0
        ma_dither_mode_rectangle = 1
        ma_dither_mode_triangle  = 2

    ctypedef enum ma_format:
        ma_format_unknown = 0
        ma_format_u8      = 1
        ma_format_s16     = 2
        ma_format_s24     = 3
        ma_format_s32     = 4
        ma_format_f32     = 5
        ma_format_count   = 6

    ctypedef enum ma_standard_sample_rate:
        ma_standard_sample_rate_48000  = 48000
        ma_standard_sample_rate_44100  = 44100
        ma_standard_sample_rate_32000  = 32000
        ma_standard_sample_rate_24000  = 24000
        ma_standard_sample_rate_22050  = 22050
        ma_standard_sample_rate_88200  = 88200
        ma_standard_sample_rate_96000  = 96000
        ma_standard_sample_rate_176400 = 176400
        ma_standard_sample_rate_192000 = 192000
        ma_standard_sample_rate_16000  = 16000
        ma_standard_sample_rate_11025  = 11250
        ma_standard_sample_rate_8000   = 8000
        ma_standard_sample_rate_352800 = 352800
        ma_standard_sample_rate_384000 = 384000
        ma_standard_sample_rate_min    = ma_standard_sample_rate_8000,
        ma_standard_sample_rate_max    = ma_standard_sample_rate_384000,
        ma_standard_sample_rate_count  = 14

    ctypedef enum ma_channel_mix_mode:
        ma_channel_mix_mode_rectangular = 0
        ma_channel_mix_mode_simple
        ma_channel_mix_mode_custom_weights
        ma_channel_mix_mode_default = ma_channel_mix_mode_rectangular

    ctypedef enum ma_standard_channel_map:
        ma_standard_channel_map_microsoft
        ma_standard_channel_map_alsa
        ma_standard_channel_map_rfc3551
        ma_standard_channel_map_flac
        ma_standard_channel_map_vorbis
        ma_standard_channel_map_sound4
        ma_standard_channel_map_sndio
        ma_standard_channel_map_webaudio = ma_standard_channel_map_flac
        ma_standard_channel_map_default = ma_standard_channel_map_microsoft

    ctypedef enum ma_performance_profile:
        ma_performance_profile_low_latency = 0
        ma_performance_profile_conservative

    ctypedef struct ma_allocation_callbacks:
        void *pUserData
        void *(*onMalloc)(size_t sz, void *pUserData)
        void *(*onRealloc)(void *p, size_t sz, void *pUserData)
        void (*onFree)(void *p, void *pUserData)

    ctypedef struct ma_lcg:
        ma_int32 state

    ctypedef enum ma_thread_priority:
        ma_thread_priority_idle = -5
        ma_thread_priority_lowest = -4
        ma_thread_priority_low = -3
        ma_thread_priority_normal = -2
        ma_thread_priority_high = -1
        ma_thread_priority_highest = 0
        ma_thread_priority_realtime = 1
        ma_thread_priority_default = 0

    ctypedef ma_uint32 ma_spinlock

    ctypedef pthread_t ma_thread

    ctypedef pthread_mutex_t ma_mutex

    ctypedef struct ma_event:
        ma_uint32 value
        pthread_mutex_t lock
        pthread_cond_t cond

    ctypedef struct ma_semaphore:
        int value
        pthread_mutex_t lock
        pthread_cond_t cond

# -----------------------------------------------------------
# get version funcs

    void ma_version(ma_uint32* pMajor, ma_uint32* pMinor, ma_uint32* pRevision)
    char* ma_version_string()

# -----------------------------------------------------------
# logging

    ctypedef enum ma_log_level:
        MA_LOG_LEVEL_DEBUG = 4
        MA_LOG_LEVEL_INFO = 3
        MA_LOG_LEVEL_WARNING = 2
        MA_LOG_LEVEL_ERROR = 1

    # The callback for handling log messages.
    ctypedef void (* ma_log_callback_proc)(void* pUserData, ma_uint32 level, const char* pMessage)

    ctypedef struct ma_log_callback:
        ma_log_callback_proc onLog
        void* pUserData

    ma_log_callback ma_log_callback_init(ma_log_callback_proc onLog, void* pUserData)

    ctypedef struct ma_log:
        ma_log_callback callbacks[4]
        ma_uint32 callbackCount
        ma_allocation_callbacks allocationCallbacks
        ma_mutex lock

    ma_result ma_log_init(const ma_allocation_callbacks* pAllocationCallbacks, ma_log* pLog)
    void ma_log_uninit(ma_log* pLog)
    ma_result ma_log_register_callback(ma_log* pLog, ma_log_callback callback)
    ma_result ma_log_unregister_callback(ma_log* pLog, ma_log_callback callback)
    ma_result ma_log_post(ma_log* pLog, ma_uint32 level, const char* pMessage)
    # ma_result ma_log_postv(ma_log* pLog, ma_uint32 level, const char* pFormat, va_list args)
    # ma_result ma_log_postf(ma_log* pLog, ma_uint32 level, const char* pFormat, ...) __attribute__((format(printf, 3, 4)))


# -----------------------------------------------------------
# Biquad Filtering

    ctypedef union ma_biquad_coefficient:
        float f32
        ma_int32 s32

    ctypedef struct ma_biquad_config:
        ma_format format
        ma_uint32 channels
        double b0
        double b1
        double b2
        double a0
        double a1
        double a2

    # API
    ma_biquad_config ma_biquad_config_init(ma_format format, ma_uint32 channels, double b0, double b1, double b2, double a0, double a1, double a2)

    ctypedef struct ma_biquad:
        ma_format format
        ma_uint32 channels
        ma_biquad_coefficient b0
        ma_biquad_coefficient b1
        ma_biquad_coefficient b2
        ma_biquad_coefficient a1
        ma_biquad_coefficient a2
        ma_biquad_coefficient* pR1
        ma_biquad_coefficient* pR2

    # API
    ma_result ma_biquad_get_heap_size(const ma_biquad_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_biquad_init_preallocated(const ma_biquad_config* pConfig, void* pHeap, ma_biquad* pBQ)
    ma_result ma_biquad_init(const ma_biquad_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_biquad* pBQ)
    void ma_biquad_uninit(ma_biquad* pBQ, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_biquad_reinit(const ma_biquad_config* pConfig, ma_biquad* pBQ)
    ma_result ma_biquad_clear_cache(ma_biquad* pBQ)
    ma_result ma_biquad_process_pcm_frames(ma_biquad* pBQ, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_biquad_get_latency(const ma_biquad* pBQ)


# -----------------------------------------------------------
# Low-Pass Filtering

    ctypedef struct ma_lpf1_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        double cutoffFrequency
        double q

    ctypedef ma_lpf1_config ma_lpf2_config

    # API
    ma_lpf1_config ma_lpf1_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, double cutoffFrequency)
    ma_lpf2_config ma_lpf2_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, double cutoffFrequency, double q)


    ctypedef struct ma_lpf1:
        ma_format format
        ma_uint32 channels
        ma_biquad_coefficient a
        ma_biquad_coefficient* pR1

    # API
    ma_result ma_lpf1_get_heap_size(const ma_lpf1_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_lpf1_init_preallocated(const ma_lpf1_config* pConfig, void* pHeap, ma_lpf1* pLPF)
    ma_result ma_lpf1_init(const ma_lpf1_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_lpf1* pLPF)
    void ma_lpf1_uninit(ma_lpf1* pLPF, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_lpf1_reinit(const ma_lpf1_config* pConfig, ma_lpf1* pLPF)
    ma_result ma_lpf1_clear_cache(ma_lpf1* pLPF)
    ma_result ma_lpf1_process_pcm_frames(ma_lpf1* pLPF, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_lpf1_get_latency(const ma_lpf1* pLPF)

    ctypedef struct ma_lpf2:
        ma_biquad bq

    # API
    ma_result ma_lpf2_get_heap_size(const ma_lpf2_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_lpf2_init_preallocated(const ma_lpf2_config* pConfig, void* pHeap, ma_lpf2* pHPF)
    ma_result ma_lpf2_init(const ma_lpf2_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_lpf2* pLPF)
    void ma_lpf2_uninit(ma_lpf2* pLPF, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_lpf2_reinit(const ma_lpf2_config* pConfig, ma_lpf2* pLPF)
    ma_result ma_lpf2_clear_cache(ma_lpf2* pLPF)
    ma_result ma_lpf2_process_pcm_frames(ma_lpf2* pLPF, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_lpf2_get_latency(const ma_lpf2* pLPF)

    ctypedef struct ma_lpf_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        double cutoffFrequency
        ma_uint32 order

    # API
    ma_lpf_config ma_lpf_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, double cutoffFrequency, ma_uint32 order)

    ctypedef struct ma_lpf:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        ma_uint32 lpf1Count
        ma_uint32 lpf2Count
        ma_lpf1* pLPF1
        ma_lpf2* pLPF2

    # API
    ma_result ma_lpf_get_heap_size(const ma_lpf_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_lpf_init_preallocated(const ma_lpf_config* pConfig, void* pHeap, ma_lpf* pLPF)
    ma_result ma_lpf_init(const ma_lpf_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_lpf* pLPF)
    void ma_lpf_uninit(ma_lpf* pLPF, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_lpf_reinit(const ma_lpf_config* pConfig, ma_lpf* pLPF)
    ma_result ma_lpf_clear_cache(ma_lpf* pLPF)
    ma_result ma_lpf_process_pcm_frames(ma_lpf* pLPF, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_lpf_get_latency(const ma_lpf* pLPF)

# -----------------------------------------------------------
# High-Pass Filtering

    ctypedef struct ma_hpf1_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        double cutoffFrequency
        double q

    ctypedef ma_hpf1_config ma_hpf2_config

    # API
    ma_hpf1_config ma_hpf1_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, double cutoffFrequency)
    ma_hpf2_config ma_hpf2_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, double cutoffFrequency, double q)

    ctypedef struct ma_hpf1:
        ma_format format
        ma_uint32 channels
        ma_biquad_coefficient a
        ma_biquad_coefficient* pR1

    # API
    ma_result ma_hpf1_get_heap_size(const ma_hpf1_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_hpf1_init_preallocated(const ma_hpf1_config* pConfig, void* pHeap, ma_hpf1* pLPF)
    ma_result ma_hpf1_init(const ma_hpf1_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_hpf1* pHPF)
    void ma_hpf1_uninit(ma_hpf1* pHPF, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_hpf1_reinit(const ma_hpf1_config* pConfig, ma_hpf1* pHPF)
    ma_result ma_hpf1_process_pcm_frames(ma_hpf1* pHPF, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_hpf1_get_latency(const ma_hpf1* pHPF)

    ctypedef struct ma_hpf2:
        ma_biquad bq

    # API
    ma_result ma_hpf2_get_heap_size(const ma_hpf2_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_hpf2_init_preallocated(const ma_hpf2_config* pConfig, void* pHeap, ma_hpf2* pHPF)
    ma_result ma_hpf2_init(const ma_hpf2_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_hpf2* pHPF)
    void ma_hpf2_uninit(ma_hpf2* pHPF, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_hpf2_reinit(const ma_hpf2_config* pConfig, ma_hpf2* pHPF)
    ma_result ma_hpf2_process_pcm_frames(ma_hpf2* pHPF, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_hpf2_get_latency(const ma_hpf2* pHPF)

    ctypedef struct ma_hpf_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        double cutoffFrequency
        ma_uint32 order

    ma_hpf_config ma_hpf_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, double cutoffFrequency, ma_uint32 order)

    ctypedef struct ma_hpf:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        ma_uint32 hpf1Count
        ma_uint32 hpf2Count
        ma_hpf1* pHPF1
        ma_hpf2* pHPF2

    # API
    ma_result ma_hpf_get_heap_size(const ma_hpf_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_hpf_init_preallocated(const ma_hpf_config* pConfig, void* pHeap, ma_hpf* pLPF)
    ma_result ma_hpf_init(const ma_hpf_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_hpf* pHPF)
    void ma_hpf_uninit(ma_hpf* pHPF, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_hpf_reinit(const ma_hpf_config* pConfig, ma_hpf* pHPF)
    ma_result ma_hpf_process_pcm_frames(ma_hpf* pHPF, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_hpf_get_latency(const ma_hpf* pHPF)

# -----------------------------------------------------------
# Band-Pass Filtering

    ctypedef struct ma_bpf2_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        double cutoffFrequency
        double q

    # API
    ma_bpf2_config ma_bpf2_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, double cutoffFrequency, double q)

    ctypedef struct ma_bpf2:
        ma_biquad bq

    # API
    ma_result ma_bpf2_get_heap_size(const ma_bpf2_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_bpf2_init_preallocated(const ma_bpf2_config* pConfig, void* pHeap, ma_bpf2* pBPF)
    ma_result ma_bpf2_init(const ma_bpf2_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_bpf2* pBPF)
    void ma_bpf2_uninit(ma_bpf2* pBPF, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_bpf2_reinit(const ma_bpf2_config* pConfig, ma_bpf2* pBPF)
    ma_result ma_bpf2_process_pcm_frames(ma_bpf2* pBPF, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_bpf2_get_latency(const ma_bpf2* pBPF)

    ctypedef struct ma_bpf_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        double cutoffFrequency
        ma_uint32 order

    # API
    ma_bpf_config ma_bpf_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, double cutoffFrequency, ma_uint32 order)

    ctypedef struct ma_bpf:
        ma_format format
        ma_uint32 channels
        ma_uint32 bpf2Count
        ma_bpf2* pBPF2

    # API
    ma_result ma_bpf_get_heap_size(const ma_bpf_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_bpf_init_preallocated(const ma_bpf_config* pConfig, void* pHeap, ma_bpf* pBPF)
    ma_result ma_bpf_init(const ma_bpf_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_bpf* pBPF)
    void ma_bpf_uninit(ma_bpf* pBPF, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_bpf_reinit(const ma_bpf_config* pConfig, ma_bpf* pBPF)
    ma_result ma_bpf_process_pcm_frames(ma_bpf* pBPF, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_bpf_get_latency(const ma_bpf* pBPF)


# -----------------------------------------------------------
# Notch Filter

    ctypedef struct ma_notch2_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        double q
        double frequency

    # API
    ma_notch2_config ma_notch2_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, double q, double frequency)

    ctypedef struct ma_notch2:
        ma_biquad bq

    # API
    ma_result ma_notch2_get_heap_size(const ma_notch2_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_notch2_init_preallocated(const ma_notch2_config* pConfig, void* pHeap, ma_notch2* pFilter)
    ma_result ma_notch2_init(const ma_notch2_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_notch2* pFilter)
    void ma_notch2_uninit(ma_notch2* pFilter, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_notch2_reinit(const ma_notch2_config* pConfig, ma_notch2* pFilter)
    ma_result ma_notch2_process_pcm_frames(ma_notch2* pFilter, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_notch2_get_latency(const ma_notch2* pFilter)


# -----------------------------------------------------------
# Peaking EQ Filter

    ctypedef struct ma_peak2_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        double gainDB
        double q
        double frequency

    ctypedef ma_peak2_config ma_peak_config

    # API
    ma_peak2_config ma_peak2_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, double gainDB, double q, double frequency)

    ctypedef struct ma_peak2:
        ma_biquad bq

    # API
    ma_result ma_peak2_get_heap_size(const ma_peak2_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_peak2_init_preallocated(const ma_peak2_config* pConfig, void* pHeap, ma_peak2* pFilter)
    ma_result ma_peak2_init(const ma_peak2_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_peak2* pFilter)
    void ma_peak2_uninit(ma_peak2* pFilter, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_peak2_reinit(const ma_peak2_config* pConfig, ma_peak2* pFilter)
    ma_result ma_peak2_process_pcm_frames(ma_peak2* pFilter, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_peak2_get_latency(const ma_peak2* pFilter)


# -----------------------------------------------------------
# Low Shelf Filter

    ctypedef struct ma_loshelf2_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        double gainDB
        double shelfSlope
        double frequency

    ctypedef ma_loshelf2_config ma_loshelf_config

    # API
    ma_loshelf2_config ma_loshelf2_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, double gainDB, double shelfSlope, double frequency)

    ctypedef struct ma_loshelf2:
        ma_biquad bq

    # API
    ma_result ma_loshelf2_get_heap_size(const ma_loshelf2_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_loshelf2_init_preallocated(const ma_loshelf2_config* pConfig, void* pHeap, ma_loshelf2* pFilter)
    ma_result ma_loshelf2_init(const ma_loshelf2_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_loshelf2* pFilter)
    void ma_loshelf2_uninit(ma_loshelf2* pFilter, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_loshelf2_reinit(const ma_loshelf2_config* pConfig, ma_loshelf2* pFilter)
    ma_result ma_loshelf2_process_pcm_frames(ma_loshelf2* pFilter, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_loshelf2_get_latency(const ma_loshelf2* pFilter)

# -----------------------------------------------------------
# High Shelf Filter

    ctypedef struct ma_hishelf2_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        double gainDB
        double shelfSlope
        double frequency

    ctypedef ma_hishelf2_config ma_hishelf_config

    # API
    ma_hishelf2_config ma_hishelf2_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, double gainDB, double shelfSlope, double frequency)

    ctypedef struct ma_hishelf2:
        ma_biquad bq

    # API
    ma_result ma_hishelf2_get_heap_size(const ma_hishelf2_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_hishelf2_init_preallocated(const ma_hishelf2_config* pConfig, void* pHeap, ma_hishelf2* pFilter)
    ma_result ma_hishelf2_init(const ma_hishelf2_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_hishelf2* pFilter)
    void ma_hishelf2_uninit(ma_hishelf2* pFilter, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_hishelf2_reinit(const ma_hishelf2_config* pConfig, ma_hishelf2* pFilter)
    ma_result ma_hishelf2_process_pcm_frames(ma_hishelf2* pFilter, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_uint32 ma_hishelf2_get_latency(const ma_hishelf2* pFilter)


# -----------------------------------------------------------
# Delay

    ctypedef struct ma_delay_config:
        ma_uint32 channels
        ma_uint32 sampleRate
        ma_uint32 delayInFrames
        ma_bool32 delayStart
        float wet
        float dry
        float decay

    # API
    ma_delay_config ma_delay_config_init(ma_uint32 channels, ma_uint32 sampleRate, ma_uint32 delayInFrames, float decay)


    ctypedef struct ma_delay:
        ma_delay_config config
        ma_uint32 cursor
        ma_uint32 bufferSizeInFrames
        float* pBuffer

    # API
    ma_result ma_delay_init(const ma_delay_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_delay* pDelay)
    void ma_delay_uninit(ma_delay* pDelay, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_delay_process_pcm_frames(ma_delay* pDelay, void* pFramesOut, const void* pFramesIn, ma_uint32 frameCount)
    void ma_delay_set_wet(ma_delay* pDelay, float value)
    float ma_delay_get_wet(const ma_delay* pDelay)
    void ma_delay_set_dry(ma_delay* pDelay, float value)
    float ma_delay_get_dry(const ma_delay* pDelay)
    void ma_delay_set_decay(ma_delay* pDelay, float value)
    float ma_delay_get_decay(const ma_delay* pDelay)


# -----------------------------------------------------------
# Gainer for smooth volume changes

    ctypedef struct  ma_gainer_config:
        ma_uint32 channels
        ma_uint32 smoothTimeInFrames

    # API
    ma_gainer_config ma_gainer_config_init(ma_uint32 channels, ma_uint32 smoothTimeInFrames)


    ctypedef struct ma_gainer:
        ma_gainer_config config
        ma_uint32 t
        float masterVolume
        float* pOldGains
        float* pNewGains

    # API
    ma_result ma_gainer_get_heap_size(const ma_gainer_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_gainer_init_preallocated(const ma_gainer_config* pConfig, void* pHeap, ma_gainer* pGainer)
    ma_result ma_gainer_init(const ma_gainer_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_gainer* pGainer)
    void ma_gainer_uninit(ma_gainer* pGainer, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_gainer_process_pcm_frames(ma_gainer* pGainer, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_result ma_gainer_set_gain(ma_gainer* pGainer, float newGain)
    ma_result ma_gainer_set_gains(ma_gainer* pGainer, float* pNewGains)
    ma_result ma_gainer_set_master_volume(ma_gainer* pGainer, float volume)
    ma_result ma_gainer_get_master_volume(const ma_gainer* pGainer, float* pVolume)


# -----------------------------------------------------------
# Stereo Panner

    ctypedef enum ma_pan_mode :
        ma_pan_mode_balance = 0
        ma_pan_mode_pan

    ctypedef struct ma_panner_config:
        ma_format format
        ma_uint32 channels
        ma_pan_mode mode
        float pan
     
    # API
    ma_panner_config ma_panner_config_init(ma_format format, ma_uint32 channels)


    ctypedef struct ma_panner:
        ma_format format
        ma_uint32 channels
        ma_pan_mode mode
        float pan

    # API
    ma_result ma_panner_init(const ma_panner_config* pConfig, ma_panner* pPanner)
    ma_result ma_panner_process_pcm_frames(ma_panner* pPanner, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    void ma_panner_set_mode(ma_panner* pPanner, ma_pan_mode mode)
    ma_pan_mode ma_panner_get_mode(const ma_panner* pPanner)
    void ma_panner_set_pan(ma_panner* pPanner, float pan)
    float ma_panner_get_pan(const ma_panner* pPanner)

# -----------------------------------------------------------
# Fader

    ctypedef struct ma_fader_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate

    # API
    ma_fader_config ma_fader_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate)

    ctypedef struct ma_fader:
        ma_fader_config config
        float volumeBeg
        float volumeEnd
        ma_uint64 lengthInFrames
        ma_int64 cursorInFrames

    # API
    ma_result ma_fader_init(const ma_fader_config* pConfig, ma_fader* pFader)
    ma_result ma_fader_process_pcm_frames(ma_fader* pFader, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    void ma_fader_get_data_format(const ma_fader* pFader, ma_format* pFormat, ma_uint32* pChannels, ma_uint32* pSampleRate)
    void ma_fader_set_fade(ma_fader* pFader, float volumeBeg, float volumeEnd, ma_uint64 lengthInFrames)
    void ma_fader_set_fade_ex(ma_fader* pFader, float volumeBeg, float volumeEnd, ma_uint64 lengthInFrames, ma_int64 startOffsetInFrames)
    float ma_fader_get_current_volume(const ma_fader* pFader)

# -----------------------------------------------------------
# Spatializer

    ctypedef struct ma_vec3f:
        float x
        float y
        float z
     

    ctypedef struct ma_atomic_vec3f:
        ma_vec3f v
        ma_spinlock lock

    ctypedef enum ma_attenuation_model:
        ma_attenuation_model_none
        ma_attenuation_model_inverse
        ma_attenuation_model_linear
        ma_attenuation_model_exponential

    ctypedef enum ma_positioning:
        ma_positioning_absolute
        ma_positioning_relative

    ctypedef enum ma_handedness:
        ma_handedness_right
        ma_handedness_left
     
    ctypedef struct ma_spatializer_listener_config:

        ma_uint32 channelsOut
        ma_channel* pChannelMapOut
        ma_handedness handedness
        float coneInnerAngleInRadians
        float coneOuterAngleInRadians
        float coneOuterGain
        float speedOfSound
        ma_vec3f worldUp

    # API
    ma_spatializer_listener_config ma_spatializer_listener_config_init(ma_uint32 channelsOut)


    ctypedef struct ma_spatializer_listener:
        ma_spatializer_listener_config config
        ma_atomic_vec3f position
        ma_atomic_vec3f direction
        ma_atomic_vec3f velocity
        ma_bool32 isEnabled

        ma_bool32 _ownsHeap
        void* _pHeap

    # API
    ma_result ma_spatializer_listener_get_heap_size(const ma_spatializer_listener_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_spatializer_listener_init_preallocated(const ma_spatializer_listener_config* pConfig, void* pHeap, ma_spatializer_listener* pListener)
    ma_result ma_spatializer_listener_init(const ma_spatializer_listener_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_spatializer_listener* pListener)
    void ma_spatializer_listener_uninit(ma_spatializer_listener* pListener, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_channel* ma_spatializer_listener_get_channel_map(ma_spatializer_listener* pListener)
    void ma_spatializer_listener_set_cone(ma_spatializer_listener* pListener, float innerAngleInRadians, float outerAngleInRadians, float outerGain)
    void ma_spatializer_listener_get_cone(const ma_spatializer_listener* pListener, float* pInnerAngleInRadians, float* pOuterAngleInRadians, float* pOuterGain)
    void ma_spatializer_listener_set_position(ma_spatializer_listener* pListener, float x, float y, float z)
    ma_vec3f ma_spatializer_listener_get_position(const ma_spatializer_listener* pListener)
    void ma_spatializer_listener_set_direction(ma_spatializer_listener* pListener, float x, float y, float z)
    ma_vec3f ma_spatializer_listener_get_direction(const ma_spatializer_listener* pListener)
    void ma_spatializer_listener_set_velocity(ma_spatializer_listener* pListener, float x, float y, float z)
    ma_vec3f ma_spatializer_listener_get_velocity(const ma_spatializer_listener* pListener)
    void ma_spatializer_listener_set_speed_of_sound(ma_spatializer_listener* pListener, float speedOfSound)
    float ma_spatializer_listener_get_speed_of_sound(const ma_spatializer_listener* pListener)
    void ma_spatializer_listener_set_world_up(ma_spatializer_listener* pListener, float x, float y, float z)
    ma_vec3f ma_spatializer_listener_get_world_up(const ma_spatializer_listener* pListener)
    void ma_spatializer_listener_set_enabled(ma_spatializer_listener* pListener, ma_bool32 isEnabled)
    ma_bool32 ma_spatializer_listener_is_enabled(const ma_spatializer_listener* pListener)


    ctypedef struct ma_spatializer_config:
        ma_uint32 channelsIn
        ma_uint32 channelsOut
        ma_channel* pChannelMapIn
        ma_attenuation_model attenuationModel
        ma_positioning positioning
        ma_handedness handedness
        float minGain
        float maxGain
        float minDistance
        float maxDistance
        float rolloff
        float coneInnerAngleInRadians
        float coneOuterAngleInRadians
        float coneOuterGain
        float dopplerFactor
        float directionalAttenuationFactor
        float minSpatializationChannelGain
        ma_uint32 gainSmoothTimeInFrames

    # API
    ma_spatializer_config ma_spatializer_config_init(ma_uint32 channelsIn, ma_uint32 channelsOut)


    ctypedef struct ma_spatializer:
        ma_uint32 channelsIn
        ma_uint32 channelsOut
        ma_channel* pChannelMapIn
        ma_attenuation_model attenuationModel
        ma_positioning positioning
        ma_handedness handedness
        float minGain
        float maxGain
        float minDistance
        float maxDistance
        float rolloff
        float coneInnerAngleInRadians
        float coneOuterAngleInRadians
        float coneOuterGain
        float dopplerFactor
        float directionalAttenuationFactor
        ma_uint32 gainSmoothTimeInFrames
        ma_atomic_vec3f position
        ma_atomic_vec3f direction
        ma_atomic_vec3f velocity
        float dopplerPitch
        float minSpatializationChannelGain
        ma_gainer gainer
        float* pNewChannelGainsOut

        void* _pHeap
        ma_bool32 _ownsHeap

    # API
    ma_result ma_spatializer_get_heap_size(const ma_spatializer_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_spatializer_init_preallocated(const ma_spatializer_config* pConfig, void* pHeap, ma_spatializer* pSpatializer)
    ma_result ma_spatializer_init(const ma_spatializer_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_spatializer* pSpatializer)
    void ma_spatializer_uninit(ma_spatializer* pSpatializer, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_spatializer_process_pcm_frames(ma_spatializer* pSpatializer, ma_spatializer_listener* pListener, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_result ma_spatializer_set_master_volume(ma_spatializer* pSpatializer, float volume)
    ma_result ma_spatializer_get_master_volume(const ma_spatializer* pSpatializer, float* pVolume)
    ma_uint32 ma_spatializer_get_input_channels(const ma_spatializer* pSpatializer)
    ma_uint32 ma_spatializer_get_output_channels(const ma_spatializer* pSpatializer)
    void ma_spatializer_set_attenuation_model(ma_spatializer* pSpatializer, ma_attenuation_model attenuationModel)
    ma_attenuation_model ma_spatializer_get_attenuation_model(const ma_spatializer* pSpatializer)
    void ma_spatializer_set_positioning(ma_spatializer* pSpatializer, ma_positioning positioning)
    ma_positioning ma_spatializer_get_positioning(const ma_spatializer* pSpatializer)
    void ma_spatializer_set_rolloff(ma_spatializer* pSpatializer, float rolloff)
    float ma_spatializer_get_rolloff(const ma_spatializer* pSpatializer)
    void ma_spatializer_set_min_gain(ma_spatializer* pSpatializer, float minGain)
    float ma_spatializer_get_min_gain(const ma_spatializer* pSpatializer)
    void ma_spatializer_set_max_gain(ma_spatializer* pSpatializer, float maxGain)
    float ma_spatializer_get_max_gain(const ma_spatializer* pSpatializer)
    void ma_spatializer_set_min_distance(ma_spatializer* pSpatializer, float minDistance)
    float ma_spatializer_get_min_distance(const ma_spatializer* pSpatializer)
    void ma_spatializer_set_max_distance(ma_spatializer* pSpatializer, float maxDistance)
    float ma_spatializer_get_max_distance(const ma_spatializer* pSpatializer)
    void ma_spatializer_set_cone(ma_spatializer* pSpatializer, float innerAngleInRadians, float outerAngleInRadians, float outerGain)
    void ma_spatializer_get_cone(const ma_spatializer* pSpatializer, float* pInnerAngleInRadians, float* pOuterAngleInRadians, float* pOuterGain)
    void ma_spatializer_set_doppler_factor(ma_spatializer* pSpatializer, float dopplerFactor)
    float ma_spatializer_get_doppler_factor(const ma_spatializer* pSpatializer)
    void ma_spatializer_set_directional_attenuation_factor(ma_spatializer* pSpatializer, float directionalAttenuationFactor)
    float ma_spatializer_get_directional_attenuation_factor(const ma_spatializer* pSpatializer)
    void ma_spatializer_set_position(ma_spatializer* pSpatializer, float x, float y, float z)
    ma_vec3f ma_spatializer_get_position(const ma_spatializer* pSpatializer)
    void ma_spatializer_set_direction(ma_spatializer* pSpatializer, float x, float y, float z)
    ma_vec3f ma_spatializer_get_direction(const ma_spatializer* pSpatializer)
    void ma_spatializer_set_velocity(ma_spatializer* pSpatializer, float x, float y, float z)
    ma_vec3f ma_spatializer_get_velocity(const ma_spatializer* pSpatializer)
    void ma_spatializer_get_relative_position_and_direction(const ma_spatializer* pSpatializer, const ma_spatializer_listener* pListener, ma_vec3f* pRelativePos, ma_vec3f* pRelativeDir)

# ===========================================================
# DATA CONVERSION SECTION

# -----------------------------------------------------------
# Resampling

    ctypedef struct ma_linear_resampler_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRateIn
        ma_uint32 sampleRateOut
        ma_uint32 lpfOrder
        double lpfNyquistFactor

    # API
    ma_linear_resampler_config ma_linear_resampler_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRateIn, ma_uint32 sampleRateOut)


    cdef union ma_linear_resampler__x0:
        float *f32
        ma_int16 *s16

    cdef union ma_linear_resampler__x1:
        float *f32
        ma_int16 *s16

    ctypedef struct ma_linear_resampler:
        ma_linear_resampler_config config
        ma_uint32 inAdvanceInt
        ma_uint32 inAdvanceFrac
        ma_uint32 inTimeInt
        ma_uint32 inTimeFrac
        ma_linear_resampler__x0 x0
        ma_linear_resampler__x1 x1
        ma_lpf lpf

    # API
    ma_result ma_linear_resampler_get_heap_size(const ma_linear_resampler_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_linear_resampler_init_preallocated(const ma_linear_resampler_config* pConfig, void* pHeap, ma_linear_resampler* pResampler)
    ma_result ma_linear_resampler_init(const ma_linear_resampler_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_linear_resampler* pResampler)
    void ma_linear_resampler_uninit(ma_linear_resampler* pResampler, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_linear_resampler_process_pcm_frames(ma_linear_resampler* pResampler, const void* pFramesIn, ma_uint64* pFrameCountIn, void* pFramesOut, ma_uint64* pFrameCountOut)
    ma_result ma_linear_resampler_set_rate(ma_linear_resampler* pResampler, ma_uint32 sampleRateIn, ma_uint32 sampleRateOut)
    ma_result ma_linear_resampler_set_rate_ratio(ma_linear_resampler* pResampler, float ratioInOut)
    ma_uint64 ma_linear_resampler_get_input_latency(const ma_linear_resampler* pResampler)
    ma_uint64 ma_linear_resampler_get_output_latency(const ma_linear_resampler* pResampler)
    ma_result ma_linear_resampler_get_required_input_frame_count(const ma_linear_resampler* pResampler, ma_uint64 outputFrameCount, ma_uint64* pInputFrameCount)
    ma_result ma_linear_resampler_get_expected_output_frame_count(const ma_linear_resampler* pResampler, ma_uint64 inputFrameCount, ma_uint64* pOutputFrameCount)
    ma_result ma_linear_resampler_reset(ma_linear_resampler* pResampler)


    ctypedef struct ma_resampler_config
    ctypedef void ma_resampling_backend 

    ctypedef struct ma_resampling_backend_vtable:
        ma_result (* onGetHeapSize )(void* pUserData, const ma_resampler_config* pConfig, size_t* pHeapSizeInBytes)
        ma_result (* onInit )(void* pUserData, const ma_resampler_config* pConfig, void* pHeap, ma_resampling_backend** ppBackend)
        void (* onUninit )(void* pUserData, ma_resampling_backend* pBackend, const ma_allocation_callbacks* pAllocationCallbacks)
        ma_result (* onProcess )(void* pUserData, ma_resampling_backend* pBackend, const void* pFramesIn, ma_uint64* pFrameCountIn, void* pFramesOut, ma_uint64* pFrameCountOut)
        ma_result (* onSetRate )(void* pUserData, ma_resampling_backend* pBackend, ma_uint32 sampleRateIn, ma_uint32 sampleRateOut)
        ma_uint64 (* onGetInputLatency )(void* pUserData, const ma_resampling_backend* pBackend)
        ma_uint64 (* onGetOutputLatency )(void* pUserData, const ma_resampling_backend* pBackend)
        ma_result (* onGetRequiredInputFrameCount )(void* pUserData, const ma_resampling_backend* pBackend, ma_uint64 outputFrameCount, ma_uint64* pInputFrameCount)
        ma_result (* onGetExpectedOutputFrameCount)(void* pUserData, const ma_resampling_backend* pBackend, ma_uint64 inputFrameCount, ma_uint64* pOutputFrameCount)
        ma_result (* onReset )(void* pUserData, ma_resampling_backend* pBackend)


    ctypedef enum ma_resample_algorithm:
        ma_resample_algorithm_linear = 0
        ma_resample_algorithm_custom

    cdef struct ma_resampler_config__linear:
        ma_uint32 lpfOrder

    ctypedef struct ma_resampler_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRateIn
        ma_uint32 sampleRateOut
        ma_resample_algorithm algorithm
        ma_resampling_backend_vtable* pBackendVTable
        void* pBackendUserData
        ma_resampler_config__linear linear

    # API
    ma_resampler_config ma_resampler_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRateIn, ma_uint32 sampleRateOut, ma_resample_algorithm algorithm)

    cdef union ma_resampler__state:
        ma_linear_resampler linear

    ctypedef struct ma_resampler:
        ma_resampling_backend* pBackend
        ma_resampling_backend_vtable* pBackendVTable
        void* pBackendUserData
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRateIn
        ma_uint32 sampleRateOut
        ma_resampler__state state

    # API
    ma_result ma_resampler_get_heap_size(const ma_resampler_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_resampler_init_preallocated(const ma_resampler_config* pConfig, void* pHeap, ma_resampler* pResampler)
    ma_result ma_resampler_init(const ma_resampler_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_resampler* pResampler)
    void ma_resampler_uninit(ma_resampler* pResampler, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_resampler_process_pcm_frames(ma_resampler* pResampler, const void* pFramesIn, ma_uint64* pFrameCountIn, void* pFramesOut, ma_uint64* pFrameCountOut)
    ma_result ma_resampler_set_rate(ma_resampler* pResampler, ma_uint32 sampleRateIn, ma_uint32 sampleRateOut)
    ma_result ma_resampler_set_rate_ratio(ma_resampler* pResampler, float ratio)
    ma_uint64 ma_resampler_get_input_latency(const ma_resampler* pResampler)
    ma_uint64 ma_resampler_get_output_latency(const ma_resampler* pResampler)
    ma_result ma_resampler_get_required_input_frame_count(const ma_resampler* pResampler, ma_uint64 outputFrameCount, ma_uint64* pInputFrameCount)
    ma_result ma_resampler_get_expected_output_frame_count(const ma_resampler* pResampler, ma_uint64 inputFrameCount, ma_uint64* pOutputFrameCount)
    ma_result ma_resampler_reset(ma_resampler* pResampler)


# -----------------------------------------------------------
# Channel Conversion

    ctypedef enum ma_channel_conversion_path:
        ma_channel_conversion_path_unknown
        ma_channel_conversion_path_passthrough
        ma_channel_conversion_path_mono_out
        ma_channel_conversion_path_mono_in
        ma_channel_conversion_path_shuffle
        ma_channel_conversion_path_weights

    ctypedef enum ma_mono_expansion_mode:
        ma_mono_expansion_mode_duplicate = 0
        ma_mono_expansion_mode_average
        ma_mono_expansion_mode_stereo_only
        ma_mono_expansion_mode_default = ma_mono_expansion_mode_duplicate

    ctypedef struct ma_channel_converter_config:
        ma_format format
        ma_uint32 channelsIn
        ma_uint32 channelsOut
        const ma_channel* pChannelMapIn
        const ma_channel* pChannelMapOut
        ma_channel_mix_mode mixingMode
        ma_bool32 calculateLFEFromSpatialChannels
        float** ppWeights

    # API
    ma_channel_converter_config ma_channel_converter_config_init(ma_format format, ma_uint32 channelsIn, const ma_channel *pChannelMapIn,ma_uint32 channelsOut, const ma_channel *pChannelMapOut,ma_channel_mix_mode mixingMode)

    cdef union ma_channel_converter__weights:
        float** f32
        ma_int32** s16

    ctypedef struct ma_channel_converter:
        ma_format format
        ma_uint32 channelsIn
        ma_uint32 channelsOut
        ma_channel_mix_mode mixingMode
        ma_channel_conversion_path conversionPath
        ma_channel* pChannelMapIn
        ma_channel* pChannelMapOut
        ma_uint8* pShuffleTable
        ma_channel_converter__weights weights


    # API
    ma_result ma_channel_converter_get_heap_size(const ma_channel_converter_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_channel_converter_init_preallocated(const ma_channel_converter_config* pConfig, void* pHeap, ma_channel_converter* pConverter)
    ma_result ma_channel_converter_init(const ma_channel_converter_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_channel_converter* pConverter)
    void ma_channel_converter_uninit(ma_channel_converter* pConverter, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_channel_converter_process_pcm_frames(ma_channel_converter* pConverter, void* pFramesOut, const void* pFramesIn, ma_uint64 frameCount)
    ma_result ma_channel_converter_get_input_channel_map(const ma_channel_converter* pConverter, ma_channel* pChannelMap, size_t channelMapCap)
    ma_result ma_channel_converter_get_output_channel_map(const ma_channel_converter* pConverter, ma_channel* pChannelMap, size_t channelMapCap)


# -----------------------------------------------------------
# Data Conversion

    ctypedef struct ma_data_converter_config:
        ma_format formatIn
        ma_format formatOut
        ma_uint32 channelsIn
        ma_uint32 channelsOut
        ma_uint32 sampleRateIn
        ma_uint32 sampleRateOut
        ma_channel* pChannelMapIn
        ma_channel* pChannelMapOut
        ma_dither_mode ditherMode
        ma_channel_mix_mode channelMixMode
        ma_bool32 calculateLFEFromSpatialChannels
        float** ppChannelWeights
        ma_bool32 allowDynamicSampleRate
        ma_resampler_config resampling

    # API
    ma_data_converter_config ma_data_converter_config_init_default()
    ma_data_converter_config ma_data_converter_config_init(ma_format formatIn, ma_format formatOut, ma_uint32 channelsIn, ma_uint32 channelsOut, ma_uint32 sampleRateIn, ma_uint32 sampleRateOut)


    ctypedef enum ma_data_converter_execution_path:
        ma_data_converter_execution_path_passthrough
        ma_data_converter_execution_path_format_only
        ma_data_converter_execution_path_channels_only
        ma_data_converter_execution_path_resample_only
        ma_data_converter_execution_path_resample_first
        ma_data_converter_execution_path_channels_first

    ctypedef struct ma_data_converter:
        ma_format formatIn
        ma_format formatOut
        ma_uint32 channelsIn
        ma_uint32 channelsOut
        ma_uint32 sampleRateIn
        ma_uint32 sampleRateOut
        ma_dither_mode ditherMode
        ma_data_converter_execution_path executionPath
        ma_channel_converter channelConverter
        ma_resampler resampler
        ma_bool8 hasPreFormatConversion
        ma_bool8 hasPostFormatConversion
        ma_bool8 hasChannelConverter
        ma_bool8 hasResampler
        ma_bool8 isPassthrough

    # API
    ma_result ma_data_converter_get_heap_size(const ma_data_converter_config* pConfig, size_t* pHeapSizeInBytes)
    ma_result ma_data_converter_init_preallocated(const ma_data_converter_config* pConfig, void* pHeap, ma_data_converter* pConverter)
    ma_result ma_data_converter_init(const ma_data_converter_config* pConfig, const ma_allocation_callbacks* pAllocationCallbacks, ma_data_converter* pConverter)
    void ma_data_converter_uninit(ma_data_converter* pConverter, const ma_allocation_callbacks* pAllocationCallbacks)
    ma_result ma_data_converter_process_pcm_frames(ma_data_converter* pConverter, const void* pFramesIn, ma_uint64* pFrameCountIn, void* pFramesOut, ma_uint64* pFrameCountOut)
    ma_result ma_data_converter_set_rate(ma_data_converter* pConverter, ma_uint32 sampleRateIn, ma_uint32 sampleRateOut)
    ma_result ma_data_converter_set_rate_ratio(ma_data_converter* pConverter, float ratioInOut)
    ma_uint64 ma_data_converter_get_input_latency(const ma_data_converter* pConverter)
    ma_uint64 ma_data_converter_get_output_latency(const ma_data_converter* pConverter)
    ma_result ma_data_converter_get_required_input_frame_count(const ma_data_converter* pConverter, ma_uint64 outputFrameCount, ma_uint64* pInputFrameCount)
    ma_result ma_data_converter_get_expected_output_frame_count(const ma_data_converter* pConverter, ma_uint64 inputFrameCount, ma_uint64* pOutputFrameCount)
    ma_result ma_data_converter_get_input_channel_map(const ma_data_converter* pConverter, ma_channel* pChannelMap, size_t channelMapCap)
    ma_result ma_data_converter_get_output_channel_map(const ma_data_converter* pConverter, ma_channel* pChannelMap, size_t channelMapCap)
    ma_result ma_data_converter_reset(ma_data_converter* pConverter)


# -----------------------------------------------------------
# Format Conversion

    # API
    void ma_pcm_u8_to_s16(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_u8_to_s24(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_u8_to_s32(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_u8_to_f32(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_s16_to_u8(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_s16_to_s24(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_s16_to_s32(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_s16_to_f32(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_s24_to_u8(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_s24_to_s16(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_s24_to_s32(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_s24_to_f32(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_s32_to_u8(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_s32_to_s16(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_s32_to_s24(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_s32_to_f32(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_f32_to_u8(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_f32_to_s16(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_f32_to_s24(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_f32_to_s32(void* pOut, const void* pIn, ma_uint64 count, ma_dither_mode ditherMode)
    void ma_pcm_convert(void* pOut, ma_format formatOut, const void* pIn, ma_format formatIn, ma_uint64 sampleCount, ma_dither_mode ditherMode)
    void ma_convert_pcm_frames_format(void* pOut, ma_format formatOut, const void* pIn, ma_format formatIn, ma_uint64 frameCount, ma_uint32 channels, ma_dither_mode ditherMode)

    void ma_deinterleave_pcm_frames(ma_format format, ma_uint32 channels, ma_uint64 frameCount, const void* pInterleavedPCMFrames, void** ppDeinterleavedPCMFrames)
    void ma_interleave_pcm_frames(ma_format format, ma_uint32 channels, ma_uint64 frameCount, const void** ppDeinterleavedPCMFrames, void* pInterleavedPCMFrames)

# -----------------------------------------------------------
# Channel Maps

    # cdef int MA_CHANNEL_INDEX_NULL = 255

    # API
    ma_channel ma_channel_map_get_channel(const ma_channel* pChannelMap, ma_uint32 channelCount, ma_uint32 channelIndex)
    void ma_channel_map_init_blank(ma_channel* pChannelMap, ma_uint32 channels)
    void ma_channel_map_init_standard(ma_standard_channel_map standardChannelMap, ma_channel* pChannelMap, size_t channelMapCap, ma_uint32 channels)
    void ma_channel_map_copy(ma_channel* pOut, const ma_channel* pIn, ma_uint32 channels)
    void ma_channel_map_copy_or_default(ma_channel* pOut, size_t channelMapCapOut, const ma_channel* pIn, ma_uint32 channels)
    ma_bool32 ma_channel_map_is_valid(const ma_channel* pChannelMap, ma_uint32 channels)
    ma_bool32 ma_channel_map_is_equal(const ma_channel* pChannelMapA, const ma_channel* pChannelMapB, ma_uint32 channels)
    ma_bool32 ma_channel_map_is_blank(const ma_channel* pChannelMap, ma_uint32 channels)
    ma_bool32 ma_channel_map_contains_channel_position(ma_uint32 channels, const ma_channel* pChannelMap, ma_channel channelPosition)
    ma_bool32 ma_channel_map_find_channel_position(ma_uint32 channels, const ma_channel* pChannelMap, ma_channel channelPosition, ma_uint32* pChannelIndex)
    size_t ma_channel_map_to_string(const ma_channel* pChannelMap, ma_uint32 channels, char* pBufferOut, size_t bufferCap)
    const char* ma_channel_position_to_string(ma_channel channel)

# -----------------------------------------------------------
# Conversion Helpers

    # API
    ma_uint64 ma_convert_frames(void* pOut, ma_uint64 frameCountOut, ma_format formatOut, ma_uint32 channelsOut, ma_uint32 sampleRateOut, const void* pIn, ma_uint64 frameCountIn, ma_format formatIn, ma_uint32 channelsIn, ma_uint32 sampleRateIn)
    ma_uint64 ma_convert_frames_ex(void* pOut, ma_uint64 frameCountOut, const void* pIn, ma_uint64 frameCountIn, const ma_data_converter_config* pConfig)

# -----------------------------------------------------------
# Data Source

    # ctypedef void ma_data_source

    # ctypedef struct ma_data_source_vtable:
    #     ma_result (* onRead)(ma_data_source* pDataSource, void* pFramesOut, ma_uint64 frameCount, ma_uint64* pFramesRead)
    #     ma_result (* onSeek)(ma_data_source* pDataSource, ma_uint64 frameIndex)
    #     ma_result (* onGetDataFormat)(ma_data_source* pDataSource, ma_format* pFormat, ma_uint32* pChannels, ma_uint32* pSampleRate, ma_channel* pChannelMap, size_t channelMapCap)
    #     ma_result (* onGetCursor)(ma_data_source* pDataSource, ma_uint64* pCursor)
    #     ma_result (* onGetLength)(ma_data_source* pDataSource, ma_uint64* pLength)
    #     ma_result (* onSetLooping)(ma_data_source* pDataSource, ma_bool32 isLooping)
    #     ma_uint32 flags

    # ctypedef ma_data_source* (* ma_data_source_get_next_proc)(ma_data_source* pDataSource)

    # ctypedef struct ma_data_source_config:
    #     const ma_data_source_vtable* vtable

    # # API
    # ma_data_source_config ma_data_source_config_init()


    # ctypedef struct ma_data_source_base:
    #     const ma_data_source_vtable* vtable
    #     ma_uint64 rangeBegInFrames
    #     ma_uint64 rangeEndInFrames
    #     ma_uint64 loopBegInFrames
    #     ma_uint64 loopEndInFrames
    #     ma_data_source* pCurrent
    #     ma_data_source* pNext
    #     ma_data_source_get_next_proc onGetNext
    #     ma_bool32 isLooping

    # # API
    # ma_result ma_data_source_init(const ma_data_source_config* pConfig, ma_data_source* pDataSource)
    # void ma_data_source_uninit(ma_data_source* pDataSource)
    # ma_result ma_data_source_read_pcm_frames(ma_data_source* pDataSource, void* pFramesOut, ma_uint64 frameCount, ma_uint64* pFramesRead)
    # ma_result ma_data_source_seek_pcm_frames(ma_data_source* pDataSource, ma_uint64 frameCount, ma_uint64* pFramesSeeked)
    # ma_result ma_data_source_seek_to_pcm_frame(ma_data_source* pDataSource, ma_uint64 frameIndex)
    # ma_result ma_data_source_get_data_format(ma_data_source* pDataSource, ma_format* pFormat, ma_uint32* pChannels, ma_uint32* pSampleRate, ma_channel* pChannelMap, size_t channelMapCap)
    # ma_result ma_data_source_get_cursor_in_pcm_frames(ma_data_source* pDataSource, ma_uint64* pCursor)
    # ma_result ma_data_source_get_length_in_pcm_frames(ma_data_source* pDataSource, ma_uint64* pLength)
    # ma_result ma_data_source_get_cursor_in_seconds(ma_data_source* pDataSource, float* pCursor)
    # ma_result ma_data_source_get_length_in_seconds(ma_data_source* pDataSource, float* pLength)
    # ma_result ma_data_source_set_looping(ma_data_source* pDataSource, ma_bool32 isLooping)
    # ma_bool32 ma_data_source_is_looping(const ma_data_source* pDataSource)
    # ma_result ma_data_source_set_range_in_pcm_frames(ma_data_source* pDataSource, ma_uint64 rangeBegInFrames, ma_uint64 rangeEndInFrames)
    # void ma_data_source_get_range_in_pcm_frames(const ma_data_source* pDataSource, ma_uint64* pRangeBegInFrames, ma_uint64* pRangeEndInFrames)
    # ma_result ma_data_source_set_loop_point_in_pcm_frames(ma_data_source* pDataSource, ma_uint64 loopBegInFrames, ma_uint64 loopEndInFrames)
    # void ma_data_source_get_loop_point_in_pcm_frames(const ma_data_source* pDataSource, ma_uint64* pLoopBegInFrames, ma_uint64* pLoopEndInFrames)
    # ma_result ma_data_source_set_current(ma_data_source* pDataSource, ma_data_source* pCurrentDataSource)
    # ma_data_source* ma_data_source_get_current(const ma_data_source* pDataSource)
    # ma_result ma_data_source_set_next(ma_data_source* pDataSource, ma_data_source* pNextDataSource)
    # ma_data_source* ma_data_source_get_next(const ma_data_source* pDataSource)
    # ma_result ma_data_source_set_next_callback(ma_data_source* pDataSource, ma_data_source_get_next_proc onGetNext)
    # ma_data_source_get_next_proc ma_data_source_get_next_callback(const ma_data_source* pDataSource)


    # ctypedef struct ma_audio_buffer_ref:
    #     ma_data_source_base ds
    #     ma_format format
    #     ma_uint32 channels
    #     ma_uint32 sampleRate
    #     ma_uint64 cursor
    #     ma_uint64 sizeInFrames
    #     const void* pData

    # ma_result ma_audio_buffer_ref_init(ma_format format, ma_uint32 channels, const void* pData, ma_uint64 sizeInFrames, ma_audio_buffer_ref* pAudioBufferRef)
    # void ma_audio_buffer_ref_uninit(ma_audio_buffer_ref* pAudioBufferRef)
    # ma_result ma_audio_buffer_ref_set_data(ma_audio_buffer_ref* pAudioBufferRef, const void* pData, ma_uint64 sizeInFrames)
    # ma_uint64 ma_audio_buffer_ref_read_pcm_frames(ma_audio_buffer_ref* pAudioBufferRef, void* pFramesOut, ma_uint64 frameCount, ma_bool32 loop)
    # ma_result ma_audio_buffer_ref_seek_to_pcm_frame(ma_audio_buffer_ref* pAudioBufferRef, ma_uint64 frameIndex)
    # ma_result ma_audio_buffer_ref_map(ma_audio_buffer_ref* pAudioBufferRef, void** ppFramesOut, ma_uint64* pFrameCount)
    # ma_result ma_audio_buffer_ref_unmap(ma_audio_buffer_ref* pAudioBufferRef, ma_uint64 frameCount)
    # ma_bool32 ma_audio_buffer_ref_at_end(const ma_audio_buffer_ref* pAudioBufferRef)
    # ma_result ma_audio_buffer_ref_get_cursor_in_pcm_frames(const ma_audio_buffer_ref* pAudioBufferRef, ma_uint64* pCursor)
    # ma_result ma_audio_buffer_ref_get_length_in_pcm_frames(const ma_audio_buffer_ref* pAudioBufferRef, ma_uint64* pLength)
    # ma_result ma_audio_buffer_ref_get_available_frames(const ma_audio_buffer_ref* pAudioBufferRef, ma_uint64* pAvailableFrames)

    # ctypedef struct ma_audio_buffer_config:
    #     ma_format format
    #     ma_uint32 channels
    #     ma_uint32 sampleRate
    #     ma_uint64 sizeInFrames
    #     const void* pData
    #     ma_allocation_callbacks allocationCallbacks

    # ma_audio_buffer_config ma_audio_buffer_config_init(ma_format format, ma_uint32 channels, ma_uint64 sizeInFrames, const void* pData, const ma_allocation_callbacks* pAllocationCallbacks)

    # ctypedef struct ma_audio_buffer:
    #     ma_audio_buffer_ref ref
    #     ma_allocation_callbacks allocationCallbacks
    #     ma_bool32 ownsData
    #     ma_uint8 _pExtraData[1]

    # ma_result ma_audio_buffer_init(const ma_audio_buffer_config* pConfig, ma_audio_buffer* pAudioBuffer)
    # ma_result ma_audio_buffer_init_copy(const ma_audio_buffer_config* pConfig, ma_audio_buffer* pAudioBuffer)
    # ma_result ma_audio_buffer_alloc_and_init(const ma_audio_buffer_config* pConfig, ma_audio_buffer** ppAudioBuffer)
    # void ma_audio_buffer_uninit(ma_audio_buffer* pAudioBuffer)
    # void ma_audio_buffer_uninit_and_free(ma_audio_buffer* pAudioBuffer)
    # ma_uint64 ma_audio_buffer_read_pcm_frames(ma_audio_buffer* pAudioBuffer, void* pFramesOut, ma_uint64 frameCount, ma_bool32 loop)
    # ma_result ma_audio_buffer_seek_to_pcm_frame(ma_audio_buffer* pAudioBuffer, ma_uint64 frameIndex)
    # ma_result ma_audio_buffer_map(ma_audio_buffer* pAudioBuffer, void** ppFramesOut, ma_uint64* pFrameCount)
    # ma_result ma_audio_buffer_unmap(ma_audio_buffer* pAudioBuffer, ma_uint64 frameCount)
    # ma_bool32 ma_audio_buffer_at_end(const ma_audio_buffer* pAudioBuffer)
    # ma_result ma_audio_buffer_get_cursor_in_pcm_frames(const ma_audio_buffer* pAudioBuffer, ma_uint64* pCursor)
    # ma_result ma_audio_buffer_get_length_in_pcm_frames(const ma_audio_buffer* pAudioBuffer, ma_uint64* pLength)
    # ma_result ma_audio_buffer_get_available_frames(const ma_audio_buffer* pAudioBuffer, ma_uint64* pAvailableFrames)


    # ctypedef struct ma_paged_audio_buffer_page

    # ctypedef struct ma_paged_audio_buffer_page:
    #     # MA_ATOMIC(MA_SIZEOF_PTR, ma_paged_audio_buffer_page*) pNext
    #     ma_uint64 sizeInFrames
    #     ma_uint8 pAudioData[1]

    # ctypedef struct ma_paged_audio_buffer_data:
    #     ma_format format
    #     ma_uint32 channels
    #     ma_paged_audio_buffer_page head
    #     # MA_ATOMIC(MA_SIZEOF_PTR, ma_paged_audio_buffer_page*) pTail

    # # API
    # ma_result ma_paged_audio_buffer_data_init(ma_format format, ma_uint32 channels, ma_paged_audio_buffer_data* pData)
    # void ma_paged_audio_buffer_data_uninit(ma_paged_audio_buffer_data* pData, const ma_allocation_callbacks* pAllocationCallbacks)
    # ma_paged_audio_buffer_page* ma_paged_audio_buffer_data_get_head(ma_paged_audio_buffer_data* pData)
    # ma_paged_audio_buffer_page* ma_paged_audio_buffer_data_get_tail(ma_paged_audio_buffer_data* pData)
    # ma_result ma_paged_audio_buffer_data_get_length_in_pcm_frames(ma_paged_audio_buffer_data* pData, ma_uint64* pLength)
    # ma_result ma_paged_audio_buffer_data_allocate_page(ma_paged_audio_buffer_data* pData, ma_uint64 pageSizeInFrames, const void* pInitialData, const ma_allocation_callbacks* pAllocationCallbacks, ma_paged_audio_buffer_page** ppPage)
    # ma_result ma_paged_audio_buffer_data_free_page(ma_paged_audio_buffer_data* pData, ma_paged_audio_buffer_page* pPage, const ma_allocation_callbacks* pAllocationCallbacks)
    # ma_result ma_paged_audio_buffer_data_append_page(ma_paged_audio_buffer_data* pData, ma_paged_audio_buffer_page* pPage)
    # ma_result ma_paged_audio_buffer_data_allocate_and_append_page(ma_paged_audio_buffer_data* pData, ma_uint32 pageSizeInFrames, const void* pInitialData, const ma_allocation_callbacks* pAllocationCallbacks)


    # ctypedef struct ma_paged_audio_buffer_config:
    #     ma_paged_audio_buffer_data* pData

    # # API
    # ma_paged_audio_buffer_config ma_paged_audio_buffer_config_init(ma_paged_audio_buffer_data* pData)


    # ctypedef struct ma_paged_audio_buffer:
    #     ma_data_source_base ds
    #     ma_paged_audio_buffer_data* pData
    #     ma_paged_audio_buffer_page* pCurrent
    #     ma_uint64 relativeCursor
    #     ma_uint64 absoluteCursor

    # ma_result ma_paged_audio_buffer_init(const ma_paged_audio_buffer_config* pConfig, ma_paged_audio_buffer* pPagedAudioBuffer)
    # void ma_paged_audio_buffer_uninit(ma_paged_audio_buffer* pPagedAudioBuffer)
    # ma_result ma_paged_audio_buffer_read_pcm_frames(ma_paged_audio_buffer* pPagedAudioBuffer, void* pFramesOut, ma_uint64 frameCount, ma_uint64* pFramesRead)
    # ma_result ma_paged_audio_buffer_seek_to_pcm_frame(ma_paged_audio_buffer* pPagedAudioBuffer, ma_uint64 frameIndex)
    # ma_result ma_paged_audio_buffer_get_cursor_in_pcm_frames(ma_paged_audio_buffer* pPagedAudioBuffer, ma_uint64* pCursor)
    # ma_result ma_paged_audio_buffer_get_length_in_pcm_frames(ma_paged_audio_buffer* pPagedAudioBuffer, ma_uint64* pLength)


# -----------------------------------------------------------
# Ring Buffer


    ctypedef struct ma_rb:
        void *pBuffer
        ma_uint32 subbufferSizeInBytes
        ma_uint32 subbufferCount
        ma_uint32 subbufferStrideInBytes
        ma_uint32 encodedReadOffset
        ma_uint32 encodedWriteOffset
        ma_bool8 ownsBuffer
        ma_bool8 clearOnWriteAcquire
        ma_allocation_callbacks allocationCallbacks


    ma_result ma_rb_init_ex(size_t subbufferSizeInBytes, size_t subbufferCount, size_t subbufferStrideInBytes, void *pOptionalPreallocatedBuffer, const ma_allocation_callbacks *pAllocationCallbacks, ma_rb *pRB)
    ma_result ma_rb_init(size_t bufferSizeInBytes, void *pOptionalPreallocatedBuffer, const ma_allocation_callbacks *pAllocationCallbacks, ma_rb *pRB)
    void ma_rb_uninit(ma_rb *pRB)
    void ma_rb_reset(ma_rb *pRB)
    ma_result ma_rb_acquire_read(ma_rb *pRB, size_t *pSizeInBytes, void **ppBufferOut)
    ma_result ma_rb_commit_read(ma_rb *pRB, size_t sizeInBytes, void *pBufferOut)
    ma_result ma_rb_acquire_write(ma_rb *pRB, size_t *pSizeInBytes, void **ppBufferOut)
    ma_result ma_rb_commit_write(ma_rb *pRB, size_t sizeInBytes, void *pBufferOut)
    ma_result ma_rb_seek_read(ma_rb *pRB, size_t offsetInBytes)
    ma_result ma_rb_seek_write(ma_rb *pRB, size_t offsetInBytes)
    ma_int32 ma_rb_pointer_distance(ma_rb *pRB)
    ma_uint32 ma_rb_available_read(ma_rb *pRB)
    ma_uint32 ma_rb_available_write(ma_rb *pRB)
    size_t ma_rb_get_subbuffer_size(ma_rb *pRB)
    size_t ma_rb_get_subbuffer_stride(ma_rb *pRB)
    size_t ma_rb_get_subbuffer_offset(ma_rb *pRB, size_t subbufferIndex)
    void *ma_rb_get_subbuffer_ptr(ma_rb *pRB, size_t subbufferIndex, void *pBuffer)


    ctypedef struct ma_pcm_rb:
        ma_rb rb
        ma_format format
        ma_uint32 channels

    ma_result ma_pcm_rb_init_ex(ma_format format, ma_uint32 channels, ma_uint32 subbufferSizeInFrames, ma_uint32 subbufferCount, ma_uint32 subbufferStrideInFrames, void *pOptionalPreallocatedBuffer, const ma_allocation_callbacks *pAllocationCallbacks, ma_pcm_rb *pRB)
    ma_result ma_pcm_rb_init(ma_format format, ma_uint32 channels, ma_uint32 bufferSizeInFrames, void *pOptionalPreallocatedBuffer, const ma_allocation_callbacks *pAllocationCallbacks, ma_pcm_rb *pRB)
    void ma_pcm_rb_uninit(ma_pcm_rb *pRB)
    void ma_pcm_rb_reset(ma_pcm_rb *pRB)
    ma_result ma_pcm_rb_acquire_read(ma_pcm_rb *pRB, ma_uint32 *pSizeInFrames, void **ppBufferOut)
    ma_result ma_pcm_rb_commit_read(ma_pcm_rb *pRB, ma_uint32 sizeInFrames, void *pBufferOut)
    ma_result ma_pcm_rb_acquire_write(ma_pcm_rb *pRB, ma_uint32 *pSizeInFrames, void **ppBufferOut)
    ma_result ma_pcm_rb_commit_write(ma_pcm_rb *pRB, ma_uint32 sizeInFrames, void *pBufferOut)
    ma_result ma_pcm_rb_seek_read(ma_pcm_rb *pRB, ma_uint32 offsetInFrames)
    ma_result ma_pcm_rb_seek_write(ma_pcm_rb *pRB, ma_uint32 offsetInFrames)
    ma_int32 ma_pcm_rb_pointer_distance(ma_pcm_rb *pRB)
    ma_uint32 ma_pcm_rb_available_read(ma_pcm_rb *pRB)
    ma_uint32 ma_pcm_rb_available_write(ma_pcm_rb *pRB)
    ma_uint32 ma_pcm_rb_get_subbuffer_size(ma_pcm_rb *pRB)
    ma_uint32 ma_pcm_rb_get_subbuffer_stride(ma_pcm_rb *pRB)
    ma_uint32 ma_pcm_rb_get_subbuffer_offset(ma_pcm_rb *pRB, ma_uint32 subbufferIndex)
    void *ma_pcm_rb_get_subbuffer_ptr(ma_pcm_rb *pRB, ma_uint32 subbufferIndex, void *pBuffer)


    ctypedef struct ma_duplex_rb:
        ma_pcm_rb rb

    ma_result ma_duplex_rb_init(ma_format captureFormat, ma_uint32 captureChannels, ma_uint32 sampleRate, ma_uint32 captureInternalSampleRate, ma_uint32 captureInternalPeriodSizeInFrames, const ma_allocation_callbacks *pAllocationCallbacks, ma_duplex_rb *pRB)
    ma_result ma_duplex_rb_uninit(ma_duplex_rb *pRB)
    char *ma_result_description(ma_result result)
    void *ma_malloc(size_t sz, const ma_allocation_callbacks *pAllocationCallbacks)
    void *ma_realloc(void *p, size_t sz, const ma_allocation_callbacks *pAllocationCallbacks)
    void ma_free(void *p, const ma_allocation_callbacks *pAllocationCallbacks)
    void * ma_aligned_malloc(size_t sz, size_t alignment, const ma_allocation_callbacks *pAllocationCallbacks)
    void ma_aligned_free(void *p, const ma_allocation_callbacks *pAllocationCallbacks)
    char *ma_get_format_name(ma_format format)
    void ma_blend_f32(float *pOut, float *pInA, float *pInB, float factor, ma_uint32 channels)
    ma_uint32 ma_get_bytes_per_sample(ma_format format)
    ma_uint32 ma_get_bytes_per_frame(ma_format format, ma_uint32 channels)
    char *ma_log_level_to_string(ma_uint32 logLevel)


    ctypedef enum ma_backend:
        ma_backend_wasapi
        ma_backend_dsound
        ma_backend_winmm
        ma_backend_coreaudio
        ma_backend_sndio
        ma_backend_audio4
        ma_backend_oss
        ma_backend_pulseaudio
        ma_backend_alsa
        ma_backend_jack
        ma_backend_aaudio
        ma_backend_opensl
        ma_backend_webaudio
        ma_backend_custom
        ma_backend_null


    ctypedef void (*ma_device_callback_proc)(ma_device *pDevice, void *pOutput, const void *pInput, ma_uint32 frameCount)
    ctypedef void (*ma_stop_proc)(ma_device *pDevice)
    ctypedef void (*ma_log_proc)(ma_context *pContext, ma_device *pDevice, ma_uint32 logLevel, const char *message)

    ctypedef enum ma_device_type:
        ma_device_type_playback = 1
        ma_device_type_capture  = 2
        ma_device_type_duplex   = 3
        ma_device_type_loopback = 4

    ctypedef enum ma_share_mode:
        ma_share_mode_shared = 0
        ma_share_mode_exclusive

    ctypedef enum ma_ios_session_category:
        ma_ios_session_category_default = 0
        ma_ios_session_category_none
        ma_ios_session_category_ambient
        ma_ios_session_category_solo_ambient
        ma_ios_session_category_playback
        ma_ios_session_category_record
        ma_ios_session_category_play_and_record
        ma_ios_session_category_multi_route

    ctypedef enum ma_ios_session_category_option:
        ma_ios_session_category_option_mix_with_others = 0x01
        ma_ios_session_category_option_duck_others = 0x02
        ma_ios_session_category_option_allow_bluetooth = 0x04
        ma_ios_session_category_option_default_to_speaker = 0x08
        ma_ios_session_category_option_interrupt_spoken_audio_and_mix_with_others = 0x11
        ma_ios_session_category_option_allow_bluetooth_a2dp = 0x20
        ma_ios_session_category_option_allow_air_play = 0x40

    ctypedef enum ma_opensl_stream_type:
        ma_opensl_stream_type_default = 0
        ma_opensl_stream_type_voice
        ma_opensl_stream_type_system
        ma_opensl_stream_type_ring
        ma_opensl_stream_type_media
        ma_opensl_stream_type_alarm
        ma_opensl_stream_type_notification

    ctypedef enum ma_opensl_recording_preset:
        ma_opensl_recording_preset_default = 0
        ma_opensl_recording_preset_generic
        ma_opensl_recording_preset_camcorder
        ma_opensl_recording_preset_voice_recognition
        ma_opensl_recording_preset_voice_communication
        ma_opensl_recording_preset_voice_unprocessed

    ctypedef enum ma_aaudio_usage:
        ma_aaudio_usage_default = 0
        ma_aaudio_usage_announcement
        ma_aaudio_usage_emergency
        ma_aaudio_usage_safety
        ma_aaudio_usage_vehicle_status
        ma_aaudio_usage_alarm
        ma_aaudio_usage_assistance_accessibility
        ma_aaudio_usage_assistance_navigation_guidance
        ma_aaudio_usage_assistance_sonification
        ma_aaudio_usage_assitant
        ma_aaudio_usage_game
        ma_aaudio_usage_media
        ma_aaudio_usage_notification
        ma_aaudio_usage_notification_event
        ma_aaudio_usage_notification_ringtone
        ma_aaudio_usage_voice_communication
        ma_aaudio_usage_voice_communication_signalling

    ctypedef enum ma_aaudio_content_type:
        ma_aaudio_content_type_default = 0
        ma_aaudio_content_type_movie
        ma_aaudio_content_type_music
        ma_aaudio_content_type_sonification
        ma_aaudio_content_type_speech


    ctypedef enum ma_aaudio_input_preset:
        ma_aaudio_input_preset_default = 0
        ma_aaudio_input_preset_generic
        ma_aaudio_input_preset_camcorder
        ma_aaudio_input_preset_unprocessed
        ma_aaudio_input_preset_voice_recognition
        ma_aaudio_input_preset_voice_communication
        ma_aaudio_input_preset_voice_performance

    ctypedef union ma_timer:
        ma_int64 counter
        double counterD

    cdef union ma_device_id__custom:
        int i
        char s[256]
        void *p

    ctypedef union ma_device_id:
        wchar_t wasapi[64]
        ma_uint8 dsound[16]
        ma_uint32 winmm
        char alsa[256]
        char pulse[256]
        int jack
        char coreaudio[256]
        char sndio[256]
        char audio4[256]
        char oss[64]
        ma_int32 aaudio
        ma_uint32 opensl
        char webaudio[32]
        ma_device_id__custom custom
        int nullbackend

    ctypedef struct ma_context_config

    cdef struct ma_device_info__nativeDataFormats:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        ma_uint32 flags

    ctypedef struct ma_device_info:
        ma_device_id id
        char name[256]
        ma_bool32 isDefault

        ma_uint32 formatCount
        ma_format formats[6]
        ma_uint32 minChannels
        ma_uint32 maxChannels
        ma_uint32 minSampleRate
        ma_uint32 maxSampleRate

        ma_uint32 nativeDataFormatCount
        ma_device_info__nativeDataFormats nativeDataFormats[64]
    

    # ----------------------------------------------------------------------
    # RESTART HERE <--
    # ----------------------------------------------------------------------

    cdef struct ma_device_config__resampling__linear:
        ma_uint32 lpfOrder

    cdef struct ma_device_config__resampling__speex:
        int quality

    cdef struct ma_device_config__resampling:
        ma_resample_algorithm algorithm
        ma_device_config__resampling__linear linear
        ma_device_config__resampling__speex speex

    cdef struct ma_device_config__playback:
        ma_device_id* pDeviceID
        ma_format format
        ma_uint32 channels
        ma_channel channelMap[MA_MAX_CHANNELS]
        ma_channel_mix_mode channelMixMode
        ma_share_mode shareMode

    cdef struct ma_device_config__capture:
        ma_device_id* pDeviceID
        ma_format format
        ma_uint32 channels
        ma_channel channelMap[MA_MAX_CHANNELS]
        ma_channel_mix_mode channelMixMode
        ma_share_mode shareMode

    cdef struct ma_device_config__wasapi:
        ma_bool8 noAutoConvertSRC
        ma_bool8 noDefaultQualitySRC
        ma_bool8 noAutoStreamRouting
        ma_bool8 noHardwareOffloading

    cdef struct ma_device_config__alsa:
        ma_bool32 noMMap
        ma_bool32 noAutoFormat
        ma_bool32 noAutoChannels
        ma_bool32 noAutoResample

    cdef struct ma_device_config__pulse:
        char *pStreamNamePlayback
        char *pStreamNameCapture

    cdef struct ma_device_config__coreaudio:
        ma_bool32 allowNominalSampleRateChange

    cdef struct ma_device_config__opensl:
        ma_opensl_stream_type streamType
        ma_opensl_recording_preset recordingPreset

    cdef struct ma_device_config__aaudio:
        ma_aaudio_usage usage
        ma_aaudio_content_type contentType
        ma_aaudio_input_preset inputPreset

    ctypedef struct ma_device_config:
        ma_device_type deviceType
        ma_uint32 sampleRate
        ma_uint32 periodSizeInFrames
        ma_uint32 periodSizeInMilliseconds
        ma_uint32 periods
        ma_performance_profile performanceProfile
        ma_bool8 noPreZeroedOutputBuffer
        ma_bool8 noClip
        ma_device_callback_proc dataCallback
        ma_stop_proc stopCallback
        void *pUserData
        ma_device_config__resampling resampling
        ma_device_config__playback playback
        ma_device_config__capture capture
        ma_device_config__wasapi wasapi
        ma_device_config__alsa alsa
        ma_device_config__pulse pulse
        ma_device_config__coreaudio coreaudio
        ma_device_config__opensl opensl
        ma_device_config__aaudio aaudio

    ctypedef ma_bool32 (*ma_enum_devices_callback_proc)(ma_context *pContext, ma_device_type deviceType, const ma_device_info *pInfo, void *pUserData)

    ctypedef struct ma_device_descriptor:
        const ma_device_id *pDeviceID
        ma_share_mode shareMode
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        ma_channel channelMap[32]
        ma_uint32 periodSizeInFrames
        ma_uint32 periodSizeInMilliseconds
        ma_uint32 periodCount

    ctypedef struct ma_backend_callbacks:
        ma_result (*onContextInit)(ma_context *pContext, const ma_context_config *pConfig, ma_backend_callbacks *pCallbacks)
        ma_result (*onContextUninit)(ma_context *pContext)
        ma_result (*onContextEnumerateDevices)(ma_context *pContext, ma_enum_devices_callback_proc callback, void *pUserData)
        ma_result (*onContextGetDeviceInfo)(ma_context *pContext, ma_device_type deviceType, const ma_device_id *pDeviceID, ma_device_info *pDeviceInfo)
        ma_result (*onDeviceInit)(ma_device *pDevice, const ma_device_config *pConfig, ma_device_descriptor *pDescriptorPlayback, ma_device_descriptor *pDescriptorCapture)
        ma_result (*onDeviceUninit)(ma_device *pDevice)
        ma_result (*onDeviceStart)(ma_device *pDevice)
        ma_result (*onDeviceStop)(ma_device *pDevice)
        ma_result (*onDeviceRead)(ma_device *pDevice, void *pFrames, ma_uint32 frameCount, ma_uint32 *pFramesRead)
        ma_result (*onDeviceWrite)(ma_device *pDevice, const void *pFrames, ma_uint32 frameCount, ma_uint32 *pFramesWritten)
        ma_result (*onDeviceDataLoop)(ma_device *pDevice)
        ma_result (*onDeviceDataLoopWakeup)(ma_device *pDevice)

    cdef struct ma_context_config__alsa:
        ma_bool32 useVerboseDeviceEnumeration

    cdef struct ma_context_config__pulse:
        char *pApplicationName
        char *pServerName
        ma_bool32 tryAutoSpawn

    cdef struct ma_context_config__coreaudio:
        ma_ios_session_category sessionCategory
        ma_uint32 sessionCategoryOptions
        ma_bool32 noAudioSessionActivate
        ma_bool32 noAudioSessionDeactivate

    cdef struct ma_context_config__jack:
        char *pClientName
        ma_bool32 tryStartServer

    ctypedef struct ma_context_config:
        ma_log_proc logCallback
        ma_thread_priority threadPriority
        size_t threadStackSize
        void *pUserData
        ma_allocation_callbacks allocationCallbacks
        ma_context_config__alsa alsa
        ma_context_config__pulse pulse
        ma_context_config__coreaudio coreaudio
        ma_context_config__jack jack
        ma_backend_callbacks custom


    cdef struct ma_context_command__wasapi__data__quit:
        int _unused

    cdef struct ma_context_command__wasapi__data__createAudioClient:
        ma_device_type deviceType
        void *pAudioClient
        void **ppAudioClientService
        ma_result *pResult

    cdef struct ma_context_command__wasapi__data__releaseAudioClient:
        ma_device *pDevice
        ma_device_type deviceType

    cdef union ma_context_command__wasapi__data:
        ma_context_command__wasapi__data__quit quit
        ma_context_command__wasapi__data__createAudioClient createAudioClient
        ma_context_command__wasapi__data__releaseAudioClient releaseAudioClient

    ctypedef struct ma_context_command__wasapi:
        int code
        ma_event *pEvent
        ma_context_command__wasapi__data data



    cdef struct ma_context__coreaudio:
        ma_handle hCoreFoundation
        ma_proc CFStringGetCString
        ma_proc CFRelease

        ma_handle hCoreAudio
        ma_proc AudioObjectGetPropertyData
        ma_proc AudioObjectGetPropertyDataSize
        ma_proc AudioObjectSetPropertyData
        ma_proc AudioObjectAddPropertyListener
        ma_proc AudioObjectRemovePropertyListener

        ma_handle hAudioUnit
        ma_proc AudioComponentFindNext
        ma_proc AudioComponentInstanceDispose
        ma_proc AudioComponentInstanceNew
        ma_proc AudioOutputUnitStart
        ma_proc AudioOutputUnitStop
        ma_proc AudioUnitAddPropertyListener
        ma_proc AudioUnitGetPropertyInfo
        ma_proc AudioUnitGetProperty
        ma_proc AudioUnitSetProperty
        ma_proc AudioUnitInitialize
        ma_proc AudioUnitRender

        ma_ptr component
        ma_bool32 noAudioSessionDeactivate


    cdef struct ma_context__null_backend:
        int _unused

    cdef struct ma_context__posix:
        ma_handle pthreadSO
        ma_proc pthread_create
        ma_proc pthread_join
        ma_proc pthread_mutex_init
        ma_proc pthread_mutex_destroy
        ma_proc pthread_mutex_lock
        ma_proc pthread_mutex_unlock
        ma_proc pthread_cond_init
        ma_proc pthread_cond_destroy
        ma_proc pthread_cond_wait
        ma_proc pthread_cond_signal
        ma_proc pthread_attr_init
        ma_proc pthread_attr_destroy
        ma_proc pthread_attr_setschedpolicy
        ma_proc pthread_attr_getschedparam
        ma_proc pthread_attr_setschedparam

    ctypedef struct ma_context:
        ma_backend_callbacks callbacks
        ma_backend backend
        ma_log_proc logCallback
        ma_thread_priority threadPriority
        size_t threadStackSize
        void *pUserData
        ma_allocation_callbacks allocationCallbacks
        ma_mutex deviceEnumLock
        ma_mutex deviceInfoLock
        ma_uint32 deviceInfoCapacity
        ma_uint32 playbackDeviceInfoCount
        ma_uint32 captureDeviceInfoCount
        ma_device_info *pDeviceInfos

        ma_context__coreaudio coreaudio
        ma_context__null_backend null_backend
        ma_context__posix posix
        int _unused


    cdef struct ma_device__resampling__linear:
        ma_uint32 lpfOrder
    cdef struct ma_device__resampling__speex:
        int quality
    cdef struct ma_device__resampling:
        ma_resample_algorithm algorithm
        ma_device__resampling__linear linear
        ma_device__resampling__speex speex

    cdef struct ma_device__playback:
        ma_device_id id
        char name[256]
        ma_share_mode shareMode
        ma_format format
        ma_uint32 channels
        ma_channel channelMap[32]
        ma_format internalFormat
        ma_uint32 internalChannels
        ma_uint32 internalSampleRate
        ma_channel internalChannelMap[32]
        ma_uint32 internalPeriodSizeInFrames
        ma_uint32 internalPeriods
        ma_channel_mix_mode channelMixMode
        ma_data_converter converter

    cdef struct ma_device__capture:
        ma_device_id id
        char name[256]
        ma_share_mode shareMode
        ma_format format
        ma_uint32 channels
        ma_channel channelMap[32]
        ma_format internalFormat
        ma_uint32 internalChannels
        ma_uint32 internalSampleRate
        ma_channel internalChannelMap[32]
        ma_uint32 internalPeriodSizeInFrames
        ma_uint32 internalPeriods
        ma_channel_mix_mode channelMixMode
        ma_data_converter converter

    cdef struct ma_device__coreaudio:
        ma_uint32 deviceObjectIDPlayback
        ma_uint32 deviceObjectIDCapture
        ma_ptr audioUnitPlayback
        ma_ptr audioUnitCapture
        ma_ptr pAudioBufferList
        ma_uint32 audioBufferCapInFrames
        ma_event stopEvent
        ma_uint32 originalPeriodSizeInFrames
        ma_uint32 originalPeriodSizeInMilliseconds
        ma_uint32 originalPeriods
        ma_performance_profile originalPerformanceProfile
        ma_bool32 isDefaultPlaybackDevice
        ma_bool32 isDefaultCaptureDevice
        ma_bool32 isSwitchingPlaybackDevice
        ma_bool32 isSwitchingCaptureDevice
        void *pRouteChangeHandler


    cdef struct ma_device__null_device:
        ma_thread deviceThread
        ma_event operationEvent
        ma_event operationCompletionEvent
        ma_semaphore operationSemaphore
        ma_uint32 operation
        ma_result operationResult
        ma_timer timer
        double priorRunTime
        ma_uint32 currentPeriodFramesRemainingPlayback
        ma_uint32 currentPeriodFramesRemainingCapture
        ma_uint64 lastProcessedFramePlayback
        ma_uint64 lastProcessedFrameCapture
        ma_bool32 isStarted

    ctypedef struct ma_device:
        ma_context *pContext
        ma_device_type type
        ma_uint32 sampleRate
        ma_uint32 state
        ma_device_callback_proc onData
        ma_stop_proc onStop
        void *pUserData
        ma_mutex startStopLock
        ma_event wakeupEvent
        ma_event startEvent
        ma_event stopEvent
        ma_thread thread
        ma_result workResult
        ma_bool8 isOwnerOfContext
        ma_bool8 noPreZeroedOutputBuffer
        ma_bool8 noClip
        float masterVolumeFactor
        ma_duplex_rb duplexRB
        ma_device__resampling resampling
        ma_device__playback playback
        ma_device__capture capture
        ma_device__coreaudio coreaudio
        ma_device__null_device null_device
        

    ma_context_config ma_context_config_init()
    ma_result ma_context_init(const ma_backend backends[], ma_uint32 backendCount, const ma_context_config *pConfig, ma_context *pContext)
    ma_result ma_context_uninit(ma_context *pContext)
    size_t ma_context_sizeof()
    ma_result ma_context_enumerate_devices(ma_context *pContext, ma_enum_devices_callback_proc callback, void *pUserData)
    ma_result ma_context_get_devices(ma_context *pContext, ma_device_info **ppPlaybackDeviceInfos, ma_uint32 *pPlaybackDeviceCount, ma_device_info **ppCaptureDeviceInfos, ma_uint32 *pCaptureDeviceCount)
    ma_result ma_context_get_device_info(ma_context *pContext, ma_device_type deviceType, const ma_device_id *pDeviceID, ma_share_mode shareMode, ma_device_info *pDeviceInfo)
    ma_bool32 ma_context_is_loopback_supported(ma_context *pContext)

    ma_device_config ma_device_config_init(ma_device_type deviceType)
    ma_result ma_device_init(ma_context *pContext, const ma_device_config *pConfig, ma_device *pDevice)
    ma_result ma_device_init_ex(const ma_backend backends[], ma_uint32 backendCount, const ma_context_config *pContextConfig, const ma_device_config *pConfig, ma_device *pDevice)
    void ma_device_uninit(ma_device *pDevice)
    ma_result ma_device_start(ma_device *pDevice)
    ma_result ma_device_stop(ma_device *pDevice)
    ma_bool32 ma_device_is_started(const ma_device *pDevice)
    ma_uint32 ma_device_get_state(const ma_device *pDevice)
    ma_result ma_device_set_master_volume(ma_device *pDevice, float volume)
    ma_result ma_device_get_master_volume(ma_device *pDevice, float *pVolume)
    ma_result ma_device_set_master_gain_db(ma_device *pDevice, float gainDB)
    ma_result ma_device_get_master_gain_db(ma_device *pDevice, float *pGainDB)
    ma_result ma_device_handle_backend_data_callback(ma_device *pDevice, void *pOutput, const void *pInput, ma_uint32 frameCount)

    ma_uint32 ma_calculate_buffer_size_in_frames_from_descriptor(const ma_device_descriptor *pDescriptor, ma_uint32 nativeSampleRate, ma_performance_profile performanceProfile)

    char *ma_get_backend_name(ma_backend backend)
    ma_bool32 ma_is_backend_enabled(ma_backend backend)
    ma_result ma_get_enabled_backends(ma_backend *pBackends, size_t backendCap, size_t *pBackendCount)
    ma_bool32 ma_is_loopback_supported(ma_backend backend)

    ma_result ma_spinlock_lock(ma_spinlock *pSpinlock)
    ma_result ma_spinlock_lock_noyield(ma_spinlock *pSpinlock)
    ma_result ma_spinlock_unlock(ma_spinlock *pSpinlock)
    
    ma_result ma_mutex_init(ma_mutex *pMutex)
    void ma_mutex_uninit(ma_mutex *pMutex)
    void ma_mutex_lock(ma_mutex *pMutex)
    void ma_mutex_unlock(ma_mutex *pMutex)
    
    ma_result ma_event_init(ma_event *pEvent)
    void ma_event_uninit(ma_event *pEvent)
    ma_result ma_event_wait(ma_event *pEvent)
    ma_result ma_event_signal(ma_event *pEvent)
    ma_uint32 ma_scale_buffer_size(ma_uint32 baseBufferSize, float scale)
    ma_uint32 ma_calculate_buffer_size_in_milliseconds_from_frames( ma_uint32 bufferSizeInFrames, ma_uint32 sampleRate)
    ma_uint32 ma_calculate_buffer_size_in_frames_from_milliseconds(ma_uint32 bufferSizeInMilliseconds, ma_uint32 sampleRate)
    void ma_copy_pcm_frames(void *dst, const void *src, ma_uint64 frameCount, ma_format format, ma_uint32 channels)
    void ma_silence_pcm_frames(void *p, ma_uint64 frameCount, ma_format format, ma_uint32 channels)
    void ma_zero_pcm_frames(void *p, ma_uint64 frameCount, ma_format format, ma_uint32 channels)
    void *ma_offset_pcm_frames_ptr(void *p, ma_uint64 offsetInFrames, ma_format format, ma_uint32 channels)
    void *ma_offset_pcm_frames_const_ptr(const void *p, ma_uint64 offsetInFrames, ma_format format, ma_uint32 channels)
    float * ma_offset_pcm_frames_ptr_f32(float *p, ma_uint64 offsetInFrames, ma_uint32 channels)
    float * ma_offset_pcm_frames_const_ptr_f32(const float *p, ma_uint64 offsetInFrames, ma_uint32 channels)
    void ma_clip_samples_f32(float *p, ma_uint64 sampleCount)
    void ma_clip_pcm_frames_f32(float *p, ma_uint64 frameCount, ma_uint32 channels)
    void ma_copy_and_apply_volume_factor_u8(ma_uint8 *pSamplesOut, const ma_uint8 *pSamplesIn, ma_uint64 sampleCount, float factor)
    void ma_copy_and_apply_volume_factor_s16(ma_int16 *pSamplesOut, const ma_int16 *pSamplesIn, ma_uint64 sampleCount, float factor)
    void ma_copy_and_apply_volume_factor_s24(void *pSamplesOut, const void *pSamplesIn, ma_uint64 sampleCount, float factor)
    void ma_copy_and_apply_volume_factor_s32(ma_int32 *pSamplesOut, const ma_int32 *pSamplesIn, ma_uint64 sampleCount, float factor)
    void ma_copy_and_apply_volume_factor_f32(float *pSamplesOut, const float *pSamplesIn, ma_uint64 sampleCount, float factor)

    void ma_apply_volume_factor_u8(ma_uint8 *pSamples, ma_uint64 sampleCount, float factor)
    void ma_apply_volume_factor_s16(ma_int16 *pSamples, ma_uint64 sampleCount, float factor)
    void ma_apply_volume_factor_s24(void *pSamples, ma_uint64 sampleCount, float factor)
    void ma_apply_volume_factor_s32(ma_int32 *pSamples, ma_uint64 sampleCount, float factor)
    void ma_apply_volume_factor_f32(float *pSamples, ma_uint64 sampleCount, float factor)

    void ma_copy_and_apply_volume_factor_pcm_frames_u8( ma_uint8 *pPCMFramesOut, const ma_uint8 *pPCMFramesIn, ma_uint64 frameCount, ma_uint32 channels, float factor)

    void ma_copy_and_apply_volume_factor_pcm_frames_s16(ma_int16 *pPCMFramesOut, const ma_int16 *pPCMFramesIn, ma_uint64 frameCount, ma_uint32 channels, float factor)
    
    void ma_copy_and_apply_volume_factor_pcm_frames_s24(void *pPCMFramesOut, const void *pPCMFramesIn, ma_uint64 frameCount, ma_uint32 channels, float factor)
    
    void ma_copy_and_apply_volume_factor_pcm_frames_s32(ma_int32 *pPCMFramesOut, const ma_int32 *pPCMFramesIn, ma_uint64 frameCount, ma_uint32 channels, float factor)
    
    void ma_copy_and_apply_volume_factor_pcm_frames_f32(float *pPCMFramesOut, const float *pPCMFramesIn, ma_uint64 frameCount, ma_uint32 channels, float factor)
    
    void ma_copy_and_apply_volume_factor_pcm_frames(void *pFramesOut, const void *pFramesIn, ma_uint64 frameCount, ma_format format, ma_uint32 channels, float factor)

    void ma_apply_volume_factor_pcm_frames_u8(ma_uint8 *pFrames, ma_uint64 frameCount, ma_uint32 channels, float factor)
    void ma_apply_volume_factor_pcm_frames_s16(ma_int16 *pFrames, ma_uint64 frameCount, ma_uint32 channels, float factor)
    void ma_apply_volume_factor_pcm_frames_s24(void *pFrames, ma_uint64 frameCount, ma_uint32 channels, float factor)
    void ma_apply_volume_factor_pcm_frames_s32(ma_int32 *pFrames, ma_uint64 frameCount, ma_uint32 channels, float factor)
    void ma_apply_volume_factor_pcm_frames_f32(float *pFrames, ma_uint64 frameCount, ma_uint32 channels, float factor)
    void ma_apply_volume_factor_pcm_frames(void *pFrames, ma_uint64 frameCount, ma_format format, ma_uint32 channels, float factor)

    float ma_factor_to_gain_db(float factor)

    float ma_gain_db_to_factor(float gain)


    ctypedef void ma_data_source

    ctypedef struct ma_data_source_callbacks:
        ma_result (*onRead)(ma_data_source *pDataSource, void *pFramesOut, ma_uint64 frameCount, ma_uint64 *pFramesRead)
        ma_result (*onSeek)(ma_data_source *pDataSource, ma_uint64 frameIndex)
        ma_result (*onMap)(ma_data_source *pDataSource, void **ppFramesOut, ma_uint64 *pFrameCount)
        ma_result (*onUnmap)(ma_data_source *pDataSource, ma_uint64 frameCount)
        ma_result (*onGetDataFormat)(ma_data_source *pDataSource, ma_format *pFormat, ma_uint32 *pChannels, ma_uint32 *pSampleRate)
        ma_result (*onGetCursor)(ma_data_source *pDataSource, ma_uint64 *pCursor)
        ma_result (*onGetLength)(ma_data_source *pDataSource, ma_uint64 *pLength)


    ma_result ma_data_source_read_pcm_frames(ma_data_source *pDataSource, void *pFramesOut, ma_uint64 frameCount, ma_uint64 *pFramesRead, ma_bool32 loop)
    ma_result ma_data_source_seek_pcm_frames(ma_data_source *pDataSource, ma_uint64 frameCount, ma_uint64 *pFramesSeeked, ma_bool32 loop)
    ma_result ma_data_source_seek_to_pcm_frame(ma_data_source *pDataSource, ma_uint64 frameIndex)
    ma_result ma_data_source_map(ma_data_source *pDataSource, void **ppFramesOut, ma_uint64 *pFrameCount)
    ma_result ma_data_source_unmap(ma_data_source *pDataSource, ma_uint64 frameCount)
    ma_result ma_data_source_get_data_format(ma_data_source *pDataSource, ma_format *pFormat, ma_uint32 *pChannels, ma_uint32 *pSampleRate)
    ma_result ma_data_source_get_cursor_in_pcm_frames(ma_data_source *pDataSource, ma_uint64 *pCursor)
    ma_result ma_data_source_get_length_in_pcm_frames(ma_data_source *pDataSource, ma_uint64 *pLength)

    ctypedef struct ma_audio_buffer_ref:
        ma_data_source_callbacks ds
        ma_format format
        ma_uint32 channels
        ma_uint64 cursor
        ma_uint64 sizeInFrames
        void *pData



    ma_result ma_audio_buffer_ref_init(ma_format format, ma_uint32 channels, const void *pData, ma_uint64 sizeInFrames, ma_audio_buffer_ref *pAudioBufferRef)
    
    ma_result ma_audio_buffer_ref_set_data(ma_audio_buffer_ref *pAudioBufferRef, const void *pData, ma_uint64 sizeInFrames)
    
    ma_uint64 ma_audio_buffer_ref_read_pcm_frames(ma_audio_buffer_ref *pAudioBufferRef, void *pFramesOut, ma_uint64 frameCount, ma_bool32 loop)
    
    ma_result ma_audio_buffer_ref_seek_to_pcm_frame(ma_audio_buffer_ref *pAudioBufferRef, ma_uint64 frameIndex)
    
    ma_result ma_audio_buffer_ref_map(ma_audio_buffer_ref *pAudioBufferRef, void **ppFramesOut, ma_uint64 *pFrameCount)
    
    ma_result ma_audio_buffer_ref_unmap(ma_audio_buffer_ref *pAudioBufferRef, ma_uint64 frameCount)
    ma_result ma_audio_buffer_ref_at_end(ma_audio_buffer_ref *pAudioBufferRef)

    ma_result ma_audio_buffer_ref_get_available_frames(ma_audio_buffer_ref *pAudioBufferRef, ma_uint64 *pAvailableFrames)

    ctypedef struct ma_audio_buffer_config:
        ma_format format
        ma_uint32 channels
        ma_uint64 sizeInFrames
        const void *pData
        ma_allocation_callbacks allocationCallbacks


    ma_audio_buffer_config ma_audio_buffer_config_init( ma_format format, ma_uint32 channels, ma_uint64 sizeInFrames, const void *pData, const ma_allocation_callbacks *pAllocationCallbacks)

    ctypedef struct ma_audio_buffer:
        ma_audio_buffer_ref ref
        ma_allocation_callbacks allocationCallbacks
        ma_bool32 ownsData
        ma_uint8 _pExtraData[1]

    ma_result ma_audio_buffer_init(const ma_audio_buffer_config *pConfig, ma_audio_buffer *pAudioBuffer)
    ma_result ma_audio_buffer_init_copy(const ma_audio_buffer_config *pConfig, ma_audio_buffer *pAudioBuffer)
    ma_result ma_audio_buffer_alloc_and_init(const ma_audio_buffer_config *pConfig, ma_audio_buffer **ppAudioBuffer)
    void ma_audio_buffer_uninit(ma_audio_buffer *pAudioBuffer)
    void ma_audio_buffer_uninit_and_free(ma_audio_buffer *pAudioBuffer)    
    ma_uint64 ma_audio_buffer_read_pcm_frames(ma_audio_buffer *pAudioBuffer, void *pFramesOut, ma_uint64 frameCount, ma_bool32 loop)
    ma_result ma_audio_buffer_seek_to_pcm_frame(ma_audio_buffer *pAudioBuffer, ma_uint64 frameIndex)
    ma_result ma_audio_buffer_map(ma_audio_buffer *pAudioBuffer, void **ppFramesOut, ma_uint64 *pFrameCount)
    ma_result ma_audio_buffer_unmap(ma_audio_buffer *pAudioBuffer, ma_uint64 frameCount)
    ma_result ma_audio_buffer_at_end(ma_audio_buffer *pAudioBuffer)
    ma_result ma_audio_buffer_get_available_frames(ma_audio_buffer *pAudioBuffer, ma_uint64 *pAvailableFrames)

    ctypedef void ma_vfs

    ctypedef ma_handle ma_vfs_file

    ctypedef enum ma_seek_origin:
        ma_seek_origin_start,
        ma_seek_origin_current,
        ma_seek_origin_end


    ctypedef struct ma_file_info:
        ma_uint64 sizeInBytes


    ctypedef struct ma_vfs_callbacks:
        ma_result (*onOpen)(ma_vfs *pVFS, const char *pFilePath, ma_uint32 openMode, ma_vfs_file *pFile)
        ma_result (*onOpenW)(ma_vfs *pVFS, const wchar_t *pFilePath, ma_uint32 openMode, ma_vfs_file *pFile)
        ma_result (*onClose)(ma_vfs *pVFS, ma_vfs_file file)
        ma_result (*onRead)(ma_vfs *pVFS, ma_vfs_file file, void *pDst, size_t sizeInBytes, size_t *pBytesRead)
        ma_result (*onWrite)(ma_vfs *pVFS, ma_vfs_file file, const void *pSrc, size_t sizeInBytes, size_t *pBytesWritten)
        ma_result (*onSeek)(ma_vfs *pVFS, ma_vfs_file file, ma_int64 offset, ma_seek_origin origin)
        ma_result (*onTell)(ma_vfs *pVFS, ma_vfs_file file, ma_int64 *pCursor)
        ma_result (*onInfo)(ma_vfs *pVFS, ma_vfs_file file, ma_file_info *pInfo)


    ma_result ma_vfs_open(ma_vfs *pVFS, const char *pFilePath, ma_uint32 openMode, ma_vfs_file *pFile)
    ma_result ma_vfs_open_w(ma_vfs *pVFS, const wchar_t *pFilePath, ma_uint32 openMode, ma_vfs_file *pFile)
    ma_result ma_vfs_close(ma_vfs *pVFS, ma_vfs_file file)
    ma_result ma_vfs_read(ma_vfs *pVFS, ma_vfs_file file, void *pDst, size_t sizeInBytes, size_t *pBytesRead)
    ma_result ma_vfs_write(ma_vfs *pVFS, ma_vfs_file file, const void *pSrc, size_t sizeInBytes, size_t *pBytesWritten)
    ma_result ma_vfs_seek(ma_vfs *pVFS, ma_vfs_file file, ma_int64 offset, ma_seek_origin origin)
    ma_result ma_vfs_tell(ma_vfs *pVFS, ma_vfs_file file, ma_int64 *pCursor)
    ma_result ma_vfs_info(ma_vfs *pVFS, ma_vfs_file file, ma_file_info *pInfo)
    ma_result ma_vfs_open_and_read_file(ma_vfs *pVFS, const char *pFilePath, void **ppData, size_t *pSize, const ma_allocation_callbacks *pAllocationCallbacks)

    ctypedef struct ma_default_vfs:
        ma_vfs_callbacks cb
        ma_allocation_callbacks allocationCallbacks

    ma_result ma_default_vfs_init(ma_default_vfs *pVFS, const ma_allocation_callbacks *pAllocationCallbacks)

    ctypedef enum ma_resource_format:
        ma_resource_format_wav

    ctypedef struct ma_decoder

    ctypedef size_t (*ma_decoder_read_proc)(ma_decoder *pDecoder, void *pBufferOut, size_t bytesToRead)
    ctypedef ma_bool32 (*ma_decoder_seek_proc)(ma_decoder *pDecoder, int byteOffset, ma_seek_origin origin)
    ctypedef ma_uint64 (*ma_decoder_read_pcm_frames_proc)(ma_decoder *pDecoder, void *pFramesOut, ma_uint64 frameCount)
    ctypedef ma_result (*ma_decoder_seek_to_pcm_frame_proc)(ma_decoder *pDecoder, ma_uint64 frameIndex)
    ctypedef ma_result (*ma_decoder_uninit_proc)(ma_decoder *pDecoder)
    ctypedef ma_uint64 (*ma_decoder_get_length_in_pcm_frames_proc)(ma_decoder *pDecoder)


    cdef struct ma_decoder_config__resampling__linear:
        ma_uint32 lpfOrder

    cdef struct ma_decoder_config__resampling__speex:
        int quality    

    cdef struct ma_decoder_config__resampling:
        ma_resample_algorithm algorithm
        ma_decoder_config__resampling__linear linear
        ma_decoder_config__resampling__speex speex

    ctypedef struct ma_decoder_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        ma_channel channelMap[32]
        ma_channel_mix_mode channelMixMode
        ma_dither_mode ditherMode
        ma_decoder_config__resampling resampling
        ma_allocation_callbacks allocationCallbacks


    cdef struct ma_decoder__backend__vfs:
        ma_vfs *pVFS
        ma_vfs_file file  

    cdef struct ma_decoder__backend__memory:
        ma_uint8 *pData
        size_t dataSize
        size_t currentReadPos

    cdef union ma_decoder__backend:
        ma_decoder__backend__vfs vfs
        ma_decoder__backend__memory memory

    ctypedef struct ma_decoder:
        ma_data_source_callbacks ds
        ma_decoder_read_proc onRead
        ma_decoder_seek_proc onSeek
        void *pUserData
        ma_uint64 readPointerInBytes
        ma_uint64 readPointerInPCMFrames
        ma_format internalFormat
        ma_uint32 internalChannels
        ma_uint32 internalSampleRate
        ma_channel internalChannelMap[32]
        ma_format outputFormat
        ma_uint32 outputChannels
        ma_uint32 outputSampleRate
        ma_channel outputChannelMap[32]
        ma_data_converter converter
        ma_allocation_callbacks allocationCallbacks
        ma_decoder_read_pcm_frames_proc onReadPCMFrames
        ma_decoder_seek_to_pcm_frame_proc onSeekToPCMFrame
        ma_decoder_uninit_proc onUninit
        ma_decoder_get_length_in_pcm_frames_proc onGetLengthInPCMFrames
        void *pInternalDecoder
        ma_decoder__backend backend

    ma_decoder_config ma_decoder_config_init(ma_format outputFormat, ma_uint32 outputChannels, ma_uint32 outputSampleRate)

    ma_result ma_decoder_init(ma_decoder_read_proc onRead, ma_decoder_seek_proc onSeek, void *pUserData, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_wav(ma_decoder_read_proc onRead, ma_decoder_seek_proc onSeek, void *pUserData, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_flac(ma_decoder_read_proc onRead, ma_decoder_seek_proc onSeek, void *pUserData, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_mp3(ma_decoder_read_proc onRead, ma_decoder_seek_proc onSeek, void *pUserData, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_vorbis(ma_decoder_read_proc onRead, ma_decoder_seek_proc onSeek, void *pUserData, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_raw(ma_decoder_read_proc onRead, ma_decoder_seek_proc onSeek, void *pUserData, const ma_decoder_config *pConfigIn, const ma_decoder_config *pConfigOut, ma_decoder *pDecoder)

    ma_result ma_decoder_init_memory(const void *pData, size_t dataSize, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_memory_wav(const void *pData, size_t dataSize, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_memory_flac(const void *pData, size_t dataSize, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_memory_mp3(const void *pData, size_t dataSize, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_memory_vorbis(const void *pData, size_t dataSize, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_memory_raw(const void *pData, size_t dataSize, const ma_decoder_config *pConfigIn, const ma_decoder_config *pConfigOut, ma_decoder *pDecoder)

    ma_result ma_decoder_init_vfs(ma_vfs *pVFS, const char *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_vfs_wav(ma_vfs *pVFS, const char *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_vfs_flac(ma_vfs *pVFS, const char *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_vfs_mp3(ma_vfs *pVFS, const char *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_vfs_vorbis(ma_vfs *pVFS, const char *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_vfs_w(ma_vfs *pVFS, const wchar_t *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_vfs_wav_w(ma_vfs *pVFS, const wchar_t *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_vfs_flac_w(ma_vfs *pVFS, const wchar_t *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_vfs_mp3_w(ma_vfs *pVFS, const wchar_t *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_vfs_vorbis_w(ma_vfs *pVFS, const wchar_t *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)

    ma_result ma_decoder_init_file(const char *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_file_wav(const char *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_file_flac(const char *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_file_mp3(const char *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_file_vorbis(const char *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_file_w(const wchar_t *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_file_wav_w(const wchar_t *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_file_flac_w(const wchar_t *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_file_mp3_w(const wchar_t *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)
    ma_result ma_decoder_init_file_vorbis_w(const wchar_t *pFilePath, const ma_decoder_config *pConfig, ma_decoder *pDecoder)

    ma_result ma_decoder_uninit(ma_decoder *pDecoder)
    ma_result ma_decoder_get_cursor_in_pcm_frames(ma_decoder *pDecoder, ma_uint64 *pCursor)
    ma_uint64 ma_decoder_get_length_in_pcm_frames(ma_decoder *pDecoder)
    ma_result ma_decoder_read_pcm_frames(ma_decoder* pDecoder, void* pFramesOut, ma_uint64 frameCount, ma_uint64* pFramesRead) nogil
    ma_result ma_decoder_seek_to_pcm_frame(ma_decoder *pDecoder, ma_uint64 frameIndex)
    ma_result ma_decoder_get_available_frames(ma_decoder *pDecoder, ma_uint64 *pAvailableFrames)
    ma_result ma_decode_from_vfs(ma_vfs *pVFS, const char *pFilePath, ma_decoder_config *pConfig, ma_uint64 *pFrameCountOut, void **ppPCMFramesOut)
    ma_result ma_decode_file(const char *pFilePath, ma_decoder_config *pConfig, ma_uint64 *pFrameCountOut, void **ppPCMFramesOut)
    ma_result ma_decode_memory(const void *pData, size_t dataSize, ma_decoder_config *pConfig, ma_uint64 *pFrameCountOut, void **ppPCMFramesOut)

    ctypedef struct ma_encoder

    ctypedef size_t (*ma_encoder_write_proc)(ma_encoder *pEncoder, const void *pBufferIn, size_t bytesToWrite)
    ctypedef ma_bool32 (*ma_encoder_seek_proc)(ma_encoder *pEncoder, int byteOffset, ma_seek_origin origin)
    ctypedef ma_result (*ma_encoder_init_proc)(ma_encoder *pEncoder)
    ctypedef void (*ma_encoder_uninit_proc)(ma_encoder *pEncoder)
    ctypedef ma_uint64 (*ma_encoder_write_pcm_frames_proc)(ma_encoder *pEncoder, const void *pFramesIn, ma_uint64 frameCount)

    ctypedef struct ma_encoder_config:
        ma_resource_format resourceFormat
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        ma_allocation_callbacks allocationCallbacks

    ma_encoder_config ma_encoder_config_init(ma_resource_format resourceFormat, ma_format format, ma_uint32 channels, ma_uint32 sampleRate)

    ctypedef struct ma_encoder:
        ma_encoder_config config
        ma_encoder_write_proc onWrite
        ma_encoder_seek_proc onSeek
        ma_encoder_init_proc onInit
        ma_encoder_uninit_proc onUninit
        ma_encoder_write_pcm_frames_proc onWritePCMFrames
        void *pUserData
        void *pInternalEncoder
        void *pFile

    ma_result ma_encoder_init(ma_encoder_write_proc onWrite, ma_encoder_seek_proc onSeek, void *pUserData, const ma_encoder_config *pConfig, ma_encoder *pEncoder)
    ma_result ma_encoder_init_file(const char *pFilePath, const ma_encoder_config *pConfig, ma_encoder *pEncoder)
    ma_result ma_encoder_init_file_w(const wchar_t *pFilePath, const ma_encoder_config *pConfig, ma_encoder *pEncoder)
    void ma_encoder_uninit(ma_encoder *pEncoder)
    ma_uint64 ma_encoder_write_pcm_frames(ma_encoder *pEncoder, const void *pFramesIn, ma_uint64 frameCount)

    ctypedef enum ma_waveform_type:
        ma_waveform_type_sine,
        ma_waveform_type_square,
        ma_waveform_type_triangle,
        ma_waveform_type_sawtooth


    ctypedef struct ma_waveform_config:
        ma_format format
        ma_uint32 channels
        ma_uint32 sampleRate
        ma_waveform_type type
        double amplitude
        double frequency


    ma_waveform_config ma_waveform_config_init(ma_format format, ma_uint32 channels, ma_uint32 sampleRate, ma_waveform_type type, double amplitude, double frequency)

    ctypedef struct ma_waveform:
        ma_data_source_callbacks ds
        ma_waveform_config config
        double advance
        double time


    ma_result ma_waveform_init(const ma_waveform_config *pConfig, ma_waveform *pWaveform)
    ma_result ma_waveform_read_pcm_frames(ma_waveform* pWaveform, void* pFramesOut, ma_uint64 frameCount, ma_uint64* pFramesRead) nogil
    ma_result ma_waveform_seek_to_pcm_frame(ma_waveform *pWaveform, ma_uint64 frameIndex)
    ma_result ma_waveform_set_amplitude(ma_waveform *pWaveform, double amplitude)
    ma_result ma_waveform_set_frequency(ma_waveform *pWaveform, double frequency)
    ma_result ma_waveform_set_type(ma_waveform *pWaveform, ma_waveform_type type)
    ma_result ma_waveform_set_sample_rate(ma_waveform *pWaveform, ma_uint32 sampleRate)

    ctypedef enum ma_noise_type:
        ma_noise_type_white,
        ma_noise_type_pink,
        ma_noise_type_brownian

    ctypedef struct ma_noise_config:
        ma_format format
        ma_uint32 channels
        ma_noise_type type
        ma_int32 seed
        double amplitude
        ma_bool32 duplicateChannels


    ma_noise_config ma_noise_config_init(ma_format format, ma_uint32 channels, ma_noise_type type, ma_int32 seed, double amplitude)


    cdef struct ma_noise__state__pink:
        double bin[32][16]
        double accumulation[32]
        ma_uint32 counter[32]

    cdef struct ma_noise__state__brownian:
        double accumulation[32]

    cdef union ma_noise__state:
        ma_noise__state__pink pink
        ma_noise__state__brownian brownian

    ctypedef struct ma_noise:
        ma_data_source_callbacks ds
        ma_noise_config config
        ma_lcg lcg
        ma_noise__state state

    ma_result ma_noise_init(const ma_noise_config *pConfig, ma_noise *pNoise)
    ma_uint64 ma_noise_read_pcm_frames(ma_noise *pNoise, void *pFramesOut, ma_uint64 frameCount)
    ma_result ma_noise_set_amplitude(ma_noise *pNoise, double amplitude)
    ma_result ma_noise_set_seed(ma_noise *pNoise, ma_int32 seed)
    ma_result ma_noise_set_type(ma_noise *pNoise, ma_noise_type type)

