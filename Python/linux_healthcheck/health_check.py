# import required libraries
# ensure psutil and prettytable are installed
import psutil
import shutil
import os
import platform
import time
import socket
from subprocess import call
from prettytable import PrettyTable

def check():
#while True:

    # Clear the screen
    call('clear')
    print("=========Server Health================")
    
    # Server info
    print("\n")
    print("=========OS Info================")
    print("Operating System Type:",os.name)
    print("\nOperating System:",platform.system())
    print("\nOperating System Version:",platform.release())
    print("\nSystem Architecture:",platform.architecture())
    print("\nComputer Name:",platform.node())
    hostname = platform.node()
    ipAddr = socket.gethostbyname(hostname)
    print("\nComputer IP Address:",ipAddr)
    print("\n")
    time.sleep(2)

    # Get  Network configuration
    print("=========Network Status================")
    table = PrettyTable(['Network', 'Status', 'Speed'])
    for key in psutil.net_if_stats().keys():
        name = key
        up = "Up" if psutil.net_if_stats()[key].isup else "Down"
        speed = psutil.net_if_stats()[key].speed
        table.add_row([name, up, speed])
    print(table)
    print("\n")
    time.sleep(2)

    # Get Memory information
    print("=========Memory Usage================")
    mem_table = PrettyTable(["Total(GB)", "Used(GB)", "Available(GB)", "Percentage"])
    vm = psutil.virtual_memory()
    mem_table.add_row([
        f'{vm.total / 1e9:.3f}',
        f'{vm.used / 1e9:.3f}',
        f'{vm.available / 1e9:.3f}',
        vm.percent 
    ])
    print(mem_table)
    print("\n")
    time.sleep(2)

    # Get Disk info
    print("=========Disk Usage================")
    du_table = PrettyTable(["Total Usage(GB)", "Used(GB)", "Free(GB)", "Perecentage"])
    disk = psutil.disk_usage('/')
    du_table.add_row([
        f'{disk.total / 1e9:.3f}',
        f'{disk.used / 1e9:.3f}',
        f'{disk.free / 1e9:.3f}',
        disk.percent       
    ])
    print(du_table)
    print("\n")
    time.sleep(2)
    check_cpu()

# Additional section to output status
def check_cpu():

    usage = psutil.cpu_percent(1)
    cpu = usage < 75
    if not cpu:
        subject = f"ALERT!! CPU usage is currently {usage}% and over 75% threshold"
        print(subject)
    else:
        print("No cpu issues detected on this system!")
    # Call check_du by specifying the root partition
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
    # Call check_mem function 
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
    # Call the check_dns function by checking connectivity to google.com
    check_dns('www.google.com')
    return memory


def check_dns(website):

    try:
      ip_resolve = socket.gethostbyname(website)

    except socket.error:
        subject = "ALERT!! unable to resolve external google IP address. Check DNS configurations"
        print(subject)
    else:
        print("No DNS issues detected on this system!")

check()
