"""
Tests for pymoschooldata Python wrapper.

Minimal smoke tests - the actual data logic is tested by R testthat.
These just verify the Python wrapper imports and exposes expected functions.
"""

import pytest


def test_import_package():
    """Package imports successfully."""
    import pymoschooldata
    assert pymoschooldata is not None


def test_has_fetch_enr():
    """fetch_enr function is available."""
    import pymoschooldata
    assert hasattr(pymoschooldata, 'fetch_enr')
    assert callable(pymoschooldata.fetch_enr)


def test_has_get_available_years():
    """get_available_years function is available."""
    import pymoschooldata
    assert hasattr(pymoschooldata, 'get_available_years')
    assert callable(pymoschooldata.get_available_years)


def test_has_version():
    """Package has a version string."""
    import pymoschooldata
    assert hasattr(pymoschooldata, '__version__')
    assert isinstance(pymoschooldata.__version__, str)
