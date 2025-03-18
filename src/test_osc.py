#!/usr/bin/env python3

import subprocess
from random import randint
from time import sleep
from pythonosc.udp_client import SimpleUDPClient

IP = "127.0.0.1"
PORT = 12000


cmd = ["xrandr"]
cmd2 = ["grep", "*"]
p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
p2 = subprocess.Popen(cmd2, stdin=p.stdout, stdout=subprocess.PIPE)
p.stdout.close()
resolution_string, junk = p2.communicate()
resolution = resolution_string.split()[0]
width, height = resolution.split(b"x")
print(float(width), float(height))

client = SimpleUDPClient(IP, PORT)  # Create client
counter = 0
y = float(height) / 2

while True:
    # x = float(randint(0, 1800))
    # y = float(randint(0, 900))
    x = counter
    # print(f"sending {x}, {y}")
    client.send_message("/test", [float(x), float(y)])
    sleep(0.02)
    counter += 8
    if counter >= float(width):
        counter = 0
