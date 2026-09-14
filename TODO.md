# TODO

## Critical

## High

## Medium

## Low

- [ ] Cython-level plugin API for user-defined NodeGraph nodes -- enable custom DSP nodes without modifying `_core.pyx`, while keeping processing in C/Cython to avoid GIL overhead on the audio thread #to-investigate

## Not Planned

These items are internal utilities or require C callbacks that are difficult to expose in Python:

- `ma_slot_allocator` - Internal memory allocation utility (not useful for Python)
- Custom decoding backends - Requires C callbacks, complex to implement in Cython
- Specific device ID selection - Requires exposing `ma_device_id` which is backend-specific
