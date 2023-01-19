import random
letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
symbols = ['!', '#', '$', '%', '&', '*', '+']

print("Welcome to the PyPassword Generator! \n")
def greetings():
    try:
        global nr_letters
        global nr_symbols
        global nr_numbers
        nr_letters = int(input("How many letters would you like in your password?\n")) 
        nr_symbols = int(input("How many symbols would you like?\n"))
        nr_numbers = int(input("How many numbers would you like?\n"))
        password_length = nr_letters + nr_numbers + nr_symbols
        if nr_symbols < 1 or nr_numbers < 1:
            print("Please include at least 1 special character and 1 number \n")
            greetings()
        elif password_length >= 8 and password_length <= 40:
            password_gen()
            play_again()
        else:
            print("Please enter a number between 8 and 40")
            greetings()
    except ValueError:
        print("Please enter a valid number")
        greetings()


def password_gen():
    global password_list
    password_list = []
    #Loop over each list
    for char in range(1, nr_letters + 1):
        password_list += random.choice(letters)
    for char in range(1, nr_symbols + 1):
        password_list += random.choice(symbols)
    for char in range(1, nr_numbers + 1):
        password_list += random.choice(numbers)
    #Shuffle the password list
    random.shuffle(password_list)
    #Create password string
    password = ""
    #Loop over password list and add to password string
    for char in password_list:
        password += char
    print("Your randomly generated password is: \n")
    print(password)
    print("")    

def play_again():
    pause = input("Please press Enter to continue")
    again = input("Please type 'yes' if you would like to generate another password: \n").lower()
    while again != "yes":
        print("Goodbye!!")
        break
    else:
        greetings()

greetings()
