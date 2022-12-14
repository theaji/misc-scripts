#Purpose: Get the repository count of a particular github user


import requests #Used to make http requests
from bs4 import BeautifulSoup as bs #used to extract information from HTML files

def scrape():
#Use try/except block for error catch-all
    try:
        
    
#Get the gh username 
        github_user = input('Please enter Github username: \n')
#Store in a variable
        url = 'https://github.com/'+github_user
        print("Hang tight... checking " +url)
#Use requests module to retrieve page and soup to parse
        r = requests.get(url)
        soup = bs(r.content, 'html.parser')
#Find specific content
        repositories_count = soup.find('meta', {'name' : 'description'})['content']

        print(repositories_count)
        
#Ask to run another query
        pause = input("Press Enter to continue: \n")
        retry = input("Would you like to check another username?? Enter 'Y' OR 'N' \n").upper()
        if retry == "Y":
            scrape()
        else:
            print("Goodbye!!")

    except:
        print("Please enter a valid Github username")
                

scrape()

