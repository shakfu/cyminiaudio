cmake_minimum_required(VERSION 3.15...3.30)
project(${SKBUILD_PROJECT_NAME} VERSION ${SKBUILD_PROJECT_VERSION} LANGUAGES C)

# miniaudio library path
set(MINIAUDIO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/miniaudio/0.11.24")

find_package(Python REQUIRED COMPONENTS Interpreter Development.Module)

# Cython: generate _core.c from _core.pyx
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/_core.c
    COMMAND Python::Interpreter -m cython
        -3
        --directive embedsignature=True
        -I "${CMAKE_CURRENT_SOURCE_DIR}/src/cyminiaudio"
        "${CMAKE_CURRENT_SOURCE_DIR}/src/cyminiaudio/_core.pyx"
        -o ${CMAKE_CURRENT_BINARY_DIR}/_core.c
    DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cyminiaudio/_core.pyx
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cyminiaudio/libminiaudio.pxd
    COMMENT "Generating _core.c from _core.pyx"
)

# Build miniaudio as a static library
add_library(miniaudio STATIC
    ${MINIAUDIO_DIR}/miniaudio.c
)
target_include_directories(miniaudio PUBLIC
    ${MINIAUDIO_DIR}
)

# Platform-specific configuration
if(APPLE)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation REQUIRED)
    find_library(AUDIOTOOLBOX_LIBRARY AudioToolbox REQUIRED)
    find_library(COREAUDIO_LIBRARY CoreAudio REQUIRED)
    target_link_libraries(miniaudio PUBLIC
        ${COREFOUNDATION_LIBRARY}
        ${AUDIOTOOLBOX_LIBRARY}
        ${COREAUDIO_LIBRARY}
    )
elseif(UNIX)
    find_package(Threads REQUIRED)
    target_link_libraries(miniaudio PUBLIC
        m
        dl
        Threads::Threads
    )
endif()

# Build Python extension module
python_add_library(_core MODULE
    ${CMAKE_CURRENT_BINARY_DIR}/_core.c
    WITH_SOABI
)
target_include_directories(_core PRIVATE
    ${MINIAUDIO_DIR}
)
target_link_libraries(_core PRIVATE miniaudio)

# Install to the cyminiaudio package directory
install(TARGETS _core DESTINATION cyminiaudio)
