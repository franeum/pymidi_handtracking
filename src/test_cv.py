#!/usr/bin/env python3

import cv2
import mediapipe as mp
from pythonosc.udp_client import SimpleUDPClient
import socket


IP = "127.0.0.1"
PROCESSING_PORT = 12000
AUDIO_PORT = 15000


PROCESSING_CLIENT = SimpleUDPClient(IP, PROCESSING_PORT)
AUDIO_CLIENT = SimpleUDPClient(IP, AUDIO_PORT)

mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
mp_hands = mp.solutions.hands


def get_finger(hand_landmarks):
    indexFinger = hand_landmarks.ListFields()[0][1][8]
    indexX, indexY, indexZ = indexFinger.x, indexFinger.y, indexFinger.z
    indexZ = max(-0.5, indexZ)
    indexZ = min(0, indexZ)
    return [1 - indexX, indexY, abs(indexZ)]


# For webcam input:
cap = cv2.VideoCapture(0)
with mp_hands.Hands(
    model_complexity=0, min_detection_confidence=0.75, min_tracking_confidence=0.75
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

        res_hands = results.multi_handedness

        if res_hands:

            for n, hand in enumerate(res_hands):
                hand_kind = hand.ListFields()[0][1][0]

                landmark = results.multi_hand_landmarks[n]
                if hand_kind.label == "Left":
                    PROCESSING_CLIENT.send_message("/left", get_finger(landmark))
                    AUDIO_CLIENT.send_message("/left", get_finger(landmark))
                    print("LEFT")
                elif hand_kind.label == "Right":
                    PROCESSING_CLIENT.send_message("/right", get_finger(landmark))
                    AUDIO_CLIENT.send_message("/right", get_finger(landmark))
                    print("RIGHT")

            # print(len(results.multi_hand_landmarks))
        # Flip the image horizontally for a selfie-view display.
        cv2.imshow("MediaPipe Hands", cv2.flip(image, 1))
        if cv2.waitKey(20) & 0xFF == 27:
            break
cap.release()
