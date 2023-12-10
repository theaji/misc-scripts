# Treasure island game

print(" Welcome to Treasure Island.... \n Your mission is to find the treasure.... \n Best of luck!! \n")


def game():
    test1 = input("Would you like to go left or right? \n").lower()
    if test1 == "left":
        print("Good choice.. moving on... ")
        print("\n")
        test2 = input("You arrived at a lake, would you like to go swim or wait? \n").lower()
        print("\n")
        if test2 == "wait":
            print("Good choice.. moving on...")
            print("\n")
            test3 = input("You look around and see three doors. Which would you like to take? red, yellow or blue? \n ").lower()
            print("\n")
            if test3 == "yellow":
                print("Congrats!! You won the game!! \n")
                print("\n")
                play_again()
            elif test3 == "red":
                print("Ouch!! You were burned by fire. Game over!! \n")
                play_again()
            elif test3 == "blue":
                print("Ouch!! You were eaten by beasts. Game over!! \n")
                print("\n")
                play_again()
            else: 
                print("Ouch!! You got attacked by bears. Game over!! \n")
                print("\n")
                play_again()
        else:
            print("Ooops! You were attacked by a trout. Game over!! \n")
            print("\n")
            play_again()
    else:
        print("Ooops! You fell into a hole. Game over!! \n")
        print("\n")
        play_again()



def play_again():
    again = input("Would you like to play again? Type 'yes' or 'no' \n").lower()
    print("\n")
    while again != "yes":
        print("Thanks for playing!")
        break
    else:
        game()


        
game()
