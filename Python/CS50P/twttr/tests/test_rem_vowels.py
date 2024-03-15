from twttr import rem_vowels

def test_no_vowels():
    """testing output when no vowels are supplied"""
    assert rem_vowels("xyz") == "xyz"

def test_all_vowels():
    """testing output when only vowels are supplied"""
    assert rem_vowels("AEIOUaeiou") == ""
