from twttr import rem_vowels
import pytest

def test_mixed_case_vowels():
    """testing output when mixed case input is supplied"""
    assert rem_vowels("Hello World") == "Hll Wrld"

def test_special_characters():
    """testing output when special characters are supplied"""
    assert rem_vowels("!@#$%") == "!@#$%"

def test_empty_string():
    """testing output when an empty string is supplied"""
    assert rem_vowels("") == ""

def test_empty():
    """testing an error is raised if nothing is passed to function"""
    with pytest.raises(TypeError):
        rem_vowels()
