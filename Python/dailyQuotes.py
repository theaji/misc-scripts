import requests

r = requests.get("https://quotes.rest/qod?language=en", timeout=10)


#Convert into json
response = r.json()

#Check for successful quote retrieval

def retrieve():

    if r.status_code == 200: 
        print("Your Quote of the Day is: \n")
        reply()

    else:
        print("There was an issue retrieving quote!!")

#Print response

def reply():
    quote = response["contents"]["quotes"][0]["quote"]
    author = response["contents"]["quotes"][0]["author"]
    print(quote)
    print("- " + author)

retrieve()
