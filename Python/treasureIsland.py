#Print ascii art. 
#Ask if they would like to play again

print(" Welcome to Treasure Island.... \n Your mission is to find the treasure.... \n Best of luck!! \n")


def game():
    test1 = input("Would you like to go left or right? \n").lower()
    if test1 == "left":
        print("Good choice.. moving on... ")
        test2 = input("You arrived at a lake, would you like to go swim or wait? \n").lower()
        if test2 == "wait":
            print("Good choice.. moving on...")
            test3 = input("You look around and see three doors. Which would you like to take? red, yellow or blue? \n ").lower()
            if test3 == "yellow":
                print("Congrats!! You won the game!! \n")
                play_again()
            elif test3 == "red":
                print("Ouch!! You were burned by fire. Game over!! \n")
                play_again()
            elif test3 == "blue":
                print("Ouch!! You were eaten by beasts. Game over!! \n")
                play_again()
            else: 
                print("Ouch!! You got attacked by bears. Game over!! \n")
                play_again()
        else:
            print("Ooops! You were attacked by a trout. Game over!! \n")
            play_again()
    else:
        print("Ooops! You fell into a hole. Game over!! \n")
        play_again()



def play_again():
    again = input("Would you like to play again? Type 'yes' or 'no' \n").lower()
    while again != "yes":
        print("Thanks for playing!")
        break
    else:
        game()


        
game()
