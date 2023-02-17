import speedtest as speed

#Choose best server

def getServer():
    global server
    server = speed.Speedtest()
    server.get_best_server()
    download()

#Check download speed

def download():
    dl = server.download()
    dl = dl / 1000000
    print(f"Your download speed is {dl} Mb/s")
    upload()

#Check upload speed

def upload():
    ul = server.upload()
    ul = ul / 1000000
    print(f"Your upload speed is {ul} Mb/s")
    ping()

#Check ping

def ping():
    ping = server.results.ping
    print(f"Your ping latency is {ping} ms")


getServer()
