# Create a greeting

print("Welcome to the Band Name Generator!!! \n\n")

# Ask the user for input


def play_game():
    global name
    name = input("Please enter your first name:\n")
    """ Check if name starts with an alphabet
    and length does not exceed 20 characters"""
    if not name[0].isalpha() or len(name) >= 20:
        print("Please enter a valid name ")
        main()
    else:
        color = input("Please enter your favorite color:\n")
        if not color.isalpha():
            print("Please enter a valid color ")
            main()
        else:
            print("Your recommended band name is: " + name + " " + color)


def play_again():
    again = input("Would you like to play again? Please type 'yes' or 'no' \n").lower()
    while again != "yes":
        print("Thanks for playing " + name + ". See you next time!")
        break
    else:
        main()


def main():
    play_game()
    play_again()


main()
