"""Pytest configuration for cyminiaudio tests."""

import pytest


def pytest_configure(config):
    """Register custom markers."""
    config.addinivalue_line(
        "markers",
        "audio: mark test as interactive audio test (requires -s flag)",
    )


def pytest_collection_modifyitems(config, items):
    """Skip audio tests if output capture is enabled."""
    capture = config.getoption("capture")
    if capture != "no":
        skip_audio = pytest.mark.skip(
            reason="Audio tests require -s flag (disable capture) for input()"
        )
        for item in items:
            if "audio" in item.keywords:
                item.add_marker(skip_audio)
