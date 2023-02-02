#!/usr/bin/python3

import main

def test_calc_total():
    total = main.calc_total(4,5)
    assert total == 9

def test_calc_multiply():
    result = main.calc_multiply(10,3)
    assert result == 30
