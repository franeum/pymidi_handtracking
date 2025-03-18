#!/usr/bin/env python3

from random import randint
from time import sleep
from pythonosc.udp_client import SimpleUDPClient

ip = "127.0.0.1"
port = 1337

client = SimpleUDPClient(ip, port)  # Create client

while True:
    n = randint(0, 100)
    print(f"sending {n}")
    client.send_message("/some/address", n)
    sleep(1)
