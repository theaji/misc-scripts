#!/usr/bin/env python3
# Author: Theo

"""
Implement a program that prompts the user for a str of text.
Output that same text but with all vowels (A, E, I, O, and U) omitted.
"""

import argparse
import sys


def get_args():
    """Display help"""

    parser = argparse.ArgumentParser(description='Purpose: Remove vowels from input')
    args, unknown_args = parser.parse_known_args()

    if unknown_args:
        parser.print_help()
        sys.exit(1)
    return args

def main():
    """Main function, gets user input"""
    args = get_args()
    question = input("What is your input? ").strip()

    # check if input is empty or longer than 30 characters
    while not question or len(question) > 30:
        print("Input cannot be empty or greater than 30 characters. Please try again.")
        question = input("What is your input? ").strip()

    # call rem_vowels function to replace vowels from input
    new_question = rem_vowels(question)
    print()
    print("Your input without vowels is:", new_question)

def rem_vowels(x):
    """Function to iterate over input and remove vowels"""
    result = "".join([letter for letter in x if letter not in "AEIOUaeiou"])
    return result


if __name__ == "__main__":
    main()
