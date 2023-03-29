
import socket, shutil, psutil

def check_cpu():
    
    usage = psutil.cpu_percent(1)
    cpu = usage < 75
    if not cpu:
        subject = f"ALERT!! CPU usage is currently {usage}% and over 75% threshold"
        print(subject)
    else:
        print("No cpu issues detected on this system!")
    check_du('/')
    return cpu

def check_du(disk):
    
    du = shutil.disk_usage(disk)
    free = du.free / du.total * 100
    usage = free > 20
    if not usage:
        subject = f"ALERT!! Available DISK space is {free} and lower than 20% threshold"
        print(subject)
    else:
        print("No disk issues detected on this system!")
    check_mem()
    return usage

def check_mem():
    
    mem = psutil.virtual_memory().available
    total = mem / (1024.0 ** 2)
    memory = total > 400
    if not memory:
        subject = f"ALERT!! Available MEMORY space is {total} and under 400MB threshold"
        print(subject)
    else:
        print("No memory issues detected on this system!")
    check_lo()
    return memory

def check_lo():
    
    local_host = socket.gethostbyname('localhost')
    lhost = local_host == "127.0.0.1"
    if not lhost:
        subject = "ALERT!! unable to resolve localhost"
        print(subject)
    else:
        print("No dns issues detected on this system!")
    return lhost
    
check_cpu()
