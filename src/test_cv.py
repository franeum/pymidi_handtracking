#!/usr/bin/env python3

import cv2
import mediapipe as mp
from pythonosc.udp_client import SimpleUDPClient

IP = "127.0.0.1"
PORT = 12000
CLIENT = SimpleUDPClient(IP, PORT)

mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
mp_hands = mp.solutions.hands


# For webcam input:
cap = cv2.VideoCapture(0)
with mp_hands.Hands(
    model_complexity=0, min_detection_confidence=0.5, min_tracking_confidence=0.5
) as hands:
    while cap.isOpened():
        success, image = cap.read()
        if not success:
            print("Ignoring empty camera frame.")
            # If loading a video, use 'break' instead of 'continue'.
            continue

        # To improve performance, optionally mark the image as not writeable to
        # pass by reference.
        image.flags.writeable = False
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = hands.process(image)

        # Draw the hand annotations on the image.
        image.flags.writeable = True
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                indexFinger = hand_landmarks.ListFields()[0][1][8]
                indexX, indexY, indexZ = indexFinger.x, indexFinger.y, indexFinger.z
                indexZ = max(-0.5, indexZ)
                indexZ = min(0, indexZ)
                CLIENT.send_message("/test", [1 - indexX, indexY, abs(indexZ)])
        # Flip the image horizontally for a selfie-view display.
        # cv2.imshow("MediaPipe Hands", cv2.flip(image, 1))
        if cv2.waitKey(5) & 0xFF == 27:
            break
cap.release()
