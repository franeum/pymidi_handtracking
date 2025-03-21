#!/usr/bin/env python3

import cv2
import mediapipe as mp
from pythonosc.udp_client import SimpleUDPClient

# Configurazione OSC
IP = "127.0.0.1"
PROCESSING_PORT = 12000
AUDIO_PORT = 15000

PROCESSING_CLIENT = SimpleUDPClient(IP, PROCESSING_PORT)
AUDIO_CLIENT = SimpleUDPClient(IP, AUDIO_PORT)

# Inizializzazione Mediapipe
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
mp_hands = mp.solutions.hands


def get_finger(hand_landmarks):
    indexFinger = hand_landmarks.ListFields()[0][1][8]
    indexX, indexY, indexZ = indexFinger.x, indexFinger.y, indexFinger.z
    indexZ = max(-0.5, indexZ)
    indexZ = min(0, indexZ)
    return [1 - indexX, indexY, abs(indexZ)]


def enhance_image(image):
    """
    Migliora l'immagine per condizioni di scarsa illuminazione.
    """
    # Converti l'immagine in scala di grigi
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Applica un filtro di bilanciamento dell'illuminazione (CLAHE)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    balanced_gray = clahe.apply(gray)

    # Converti nuovamente in BGR per compatibilità con Mediapipe
    balanced_image = cv2.cvtColor(balanced_gray, cv2.COLOR_GRAY2BGR)

    # Applica un filtro Gaussiano per ridurre il rumore
    # blurred_image = cv2.GaussianBlur(balanced_image, (5, 5), 0)

    return balanced_image


# Inizializza la webcam con una risoluzione più alta
cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 800)  # Larghezza 1280
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 600)  # Altezza 720

with mp_hands.Hands(
    model_complexity=1,  # Usa un modello più complesso
    min_detection_confidence=0.25,  # Aumenta la confidence per ridurre i falsi positivi
    min_tracking_confidence=0.25,  # Aumenta la confidence per ridurre i falsi positivi
) as hands:
    while cap.isOpened():
        success, image = cap.read()
        if not success:
            print("Ignoring empty camera frame.")
            continue

        # Migliora l'immagine
        enhanced_image = enhance_image(image)

        # Passa l'immagine migliorata a Mediapipe
        enhanced_image.flags.writeable = False
        enhanced_image = cv2.cvtColor(enhanced_image, cv2.COLOR_BGR2RGB)
        results = hands.process(enhanced_image)

        # Disegna le annotazioni della mano sull'immagine
        enhanced_image.flags.writeable = True
        enhanced_image = cv2.cvtColor(enhanced_image, cv2.COLOR_RGB2BGR)

        if results.multi_handedness:
            for n, hand in enumerate(results.multi_handedness):
                hand_kind = hand.ListFields()[0][1][0]
                landmark = results.multi_hand_landmarks[n]

                if hand_kind.label == "Left":
                    PROCESSING_CLIENT.send_message("/left", get_finger(landmark))
                    # AUDIO_CLIENT.send_message("/left", get_finger(landmark))
                    print("LEFT")
                elif hand_kind.label == "Right":
                    PROCESSING_CLIENT.send_message("/right", get_finger(landmark))
                    # AUDIO_CLIENT.send_message("/right", get_finger(landmark))
                    print("RIGHT")

        # Mostra l'immagine migliorata
        cv2.imshow("Enhanced MediaPipe Hands", cv2.flip(enhanced_image, 1))
        if cv2.waitKey(5) & 0xFF == 27:
            break

cap.release()
cv2.destroyAllWindows()
