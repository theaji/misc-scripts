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
    # Format to 3 decimal places
    dl_fmt = "{:.3f}".format(dl)
    print("\n")
    print(f"Your download speed is {dl_fmt} Mb/s")
    upload()

#Check upload speed

def upload():
    ul = server.upload()
    ul = ul / 1000000
    # Format to 3 decimal places
    ul_fmt = "{:.3f}".format(ul)
    print(f"Your upload speed is {ul_fmt} Mb/s")
    ping()

#Check ping

def ping():
    ping = server.results.ping
    print(f"Your ping latency is {ping} ms")

def main():
  getServer()

if __name__ == "__main__":
    main()
