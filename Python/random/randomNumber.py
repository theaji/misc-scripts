#Import only the random integer generator from random module
from random import randint
 
#Function to explain the game to user
def display_title():
    print("Welcome to the Random Number Guessing Game!!\n")
    print(input("Press Enter to continue \n"))
    print("This game selects a random number between 1 and 10 then asks you to guess the number\n") 
    print(input("Press Enter to continue \n"))
    print("The game will let you know whether your guess is too low, too high or correct \n")
    print(input("Press Enter to continue \n"))
    print("After correctly guessing the number, you have the option to play again or exit. Good luck! \n")
    print(input("Press Enter to continue \n"))
    

#Function to play the game and allow guesses till user enters the correct number
def play_game():
    
    try: 
        guess = True
        num = randint(1,10)
        while guess:
            guess = int(input("Please Enter Your Guess: \n"))
            if guess > num:
                print("Too High!")
            elif guess < num:
                print("Too low!")
            else:
                print("Congratulations! Your guess was correct! \n")
                break
    except ValueError:
        print("Please Enter a valid number")
        main()
            
#Play again function

def play_again():
    again = input("Please type 'yes' if you would like to play again: \n").lower()
    while again != "yes":
        print("Thanks for playing! Goodbye!")
        break
    else:
        main()
        
        
#Main function of the game, calls the display_title function and play_game function
def main(): 
     play_game ()
     play_again()
     
#Call the title and main functions

display_title()
main()
