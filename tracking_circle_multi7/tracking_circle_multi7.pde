import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

HandCircle hc1;
HandCircle hc2;

ArrayList<Corda> corde; // Lista di corde
float scrollSpeed = 2;  // Velocità di scorrimento del nastro
float lastCordaTime = 0; // Tempo dell'ultima corda generata
float cordaInterval = 1000; // Intervallo di generazione delle corde (in millisecondi)

void setup() {
  size(1280, 960);
  frameRate(60);
  oscP5 = new OscP5(this, 12000);
  hc1 = new HandCircle();
  hc2 = new HandCircle();
  fullScreen(1);

  corde = new ArrayList<Corda>(); // Inizializziamo la lista di corde
}

void draw() {
  // Impostiamo lo sfondo bianco (senza trasparenza)
  background(255); 
  
  // Spostiamo tutte le corde lungo il nastro
  for (Corda corda : corde) {
    corda.updatePosition(scrollSpeed); // Aggiorniamo la posizione della corda
    corda.update(); // Aggiorniamo lo stato della corda
    corda.display(); // Disegniamo la corda
  }

  // Rimuoviamo le corde che sono uscite dallo schermo
  for (int i = corde.size() - 1; i >= 0; i--) {
    if (corde.get(i).isOffScreen()) {
      corde.remove(i); // Rimuoviamo la corda dalla lista
    }
  }

  // Generiamo nuove corde a intervalli regolari
  if (millis() - lastCordaTime > cordaInterval) {
    generateCorda();
    lastCordaTime = millis(); // Aggiorniamo il tempo dell'ultima corda generata
  }

  // Controlliamo se uno dei cerchi tocca una delle corde
  for (Corda corda : corde) {
    if (hc1.isTouchingCorda(corda)) {
      corda.startVibration(hc1.getDirection());  // Iniziamo/riavviamo la vibrazione con la direzione del cerchio
    }
    
    if (hc2.isTouchingCorda(corda)) {
      corda.startVibration(hc2.getDirection());  // Iniziamo/riavviamo la vibrazione con la direzione del cerchio
    }
  }

  // Aggiorniamo i cerchi
  hc1.update(hc2.getCenter());  // Aggiorniamo hc1 rispetto a hc2
  hc2.update(hc1.getCenter());  // Aggiorniamo hc2 rispetto a hc1
}

// Funzione per generare una nuova corda
void generateCorda() {
  float x = width; // La corda appare sul lato destro dello schermo
  float y = random(height / 4, 3 * height / 4); // Posizione Y casuale
  float angolo = random(-45, 45); // Angolo casuale tra -45° e 45°
  corde.add(new Corda(x, y, angolo)); // Aggiungiamo la corda alla lista
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/left") == true) {
    if (msg.checkTypetag("fff")) {
      float _x = msg.get(0).floatValue() * width;
      float _y = msg.get(1).floatValue() * height;
      float _z = msg.get(2).floatValue() * 200;
      hc1.osc_update(_x, _y, _z);
    }
    return;
  } else if (msg.checkAddrPattern("/right") == true) {
    if (msg.checkTypetag("fff")) {
      float _x = msg.get(0).floatValue() * width;
      float _y = msg.get(1).floatValue() * height;
      float _z = msg.get(2).floatValue() * 200;
      hc2.osc_update(_x, _y, _z);
    }
    return;
  }
}


// CORDA


class Corda {
  float x, y;              // Posizione della corda
  float angolo;            // Angolo della corda (in gradi)
  float vibrationAmplitude; // Ampiezza attuale della vibrazione
  float targetAmplitude;    // Ampiezza massima della vibrazione
  float vibrationFrequency; // Frequenza della vibrazione
  float currentPhase;       // Fase attuale della vibrazione
  float vibrationDecay;     // Fattore di smorzamento dell'ampiezza

  Corda(float x, float y, float angolo) {
    this.x = x;
    this.y = y;
    this.angolo = radians(angolo); // Convertiamo l'angolo in radianti
    this.vibrationAmplitude = 0;
    this.targetAmplitude = 50.0; // Ampiezza massima aumentata
    this.vibrationFrequency = 1.0;
    this.currentPhase = 0;
    this.vibrationDecay = 0.98;
  }

  // Funzione per aggiornare lo stato della corda
  void update() {
    // Riduciamo gradualmente l'ampiezza della vibrazione
    vibrationAmplitude *= vibrationDecay;
    
    // Se l'ampiezza è molto piccola, la fermiamo
    if (vibrationAmplitude < 0.1) {
      vibrationAmplitude = 0;
    }

    // Aggiorniamo la fase della vibrazione
    currentPhase += vibrationFrequency;
  }

  // Funzione per aggiornare la posizione della corda (scorrimento del nastro)
  void updatePosition(float scrollSpeed) {
    x -= scrollSpeed; // Spostiamo la corda verso sinistra
  }

  // Funzione per disegnare la corda con curve fluide
  void display() {
    stroke(255, 0, 0);  // Linea rossa
    noFill();
    beginShape();
    for (float t = -500; t <= 500; t += 10) { // Usiamo un parametro t per disegnare la corda
      // Moduliamo l'ampiezza della vibrazione lungo la corda (massima al centro)
      float modulazioneAmpiezza = map(abs(t), 0, 500, 1, 0); // Attenuazione parabolica
      float offset = sin(currentPhase + t * 0.01) * vibrationAmplitude * modulazioneAmpiezza; // Oscillazione sinusoidale
      
      // Calcoliamo la posizione X e Y lungo la corda
      float cordaX = x + t * cos(angolo) + offset * cos(angolo + HALF_PI); // Calcoliamo la posizione X
      float cordaY = y + t * sin(angolo) + offset * sin(angolo + HALF_PI); // Calcoliamo la posizione Y
      
      vertex(cordaX, cordaY); // Aggiungiamo un punto alla forma
    }
    endShape();
  }

  // Funzione per iniziare/riavviare la vibrazione della corda
  void startVibration(float direction) {
    vibrationAmplitude = targetAmplitude; // Reimpostiamo l'ampiezza massima
  }

  // Funzione per verificare se la corda è uscita dallo schermo
  boolean isOffScreen() {
    return x + 500 * cos(angolo) < 0; // La corda è uscita dallo schermo se la sua estremità sinistra è fuori
  }
}

class HandCircle {
  float startX, startY;
  float targetX, targetY;
  float radius;
  float maxRadius = 20.0;  // Raggio iniziale
  float distanceThreshold = 100; // Distanza minima per evitare il contatto
  float moveSpeed = 0.05;  // Velocità del movimento
  float prevX;             // Posizione precedente per calcolare la direzione
  
  HandCircle() {
    startX = width / 2;
    startY = height / 2;
    targetX = startX;
    targetY = startY;
    radius = maxRadius;
    prevX = startX;
  }
  
  void update(PVector otherCenter) {
    // Calcoliamo la distanza tra i cerchi
    float dx = targetX - startX;
    float dy = targetY - startY;
    
    // Aggiorniamo il movimento del cerchio (spostamento graduale)
    startX += dx * moveSpeed;
    startY += dy * moveSpeed;
    
    // Disegniamo il cerchio come un cerchio perfetto
    noStroke();
    fill(0, 200); // Assicurati che il cerchio sia disegnato correttamente
    circle(startX, startY, radius * 2);  // Disegnamo un cerchio normale
  }
  
  void osc_update(float x, float y, float z) {
    targetX = x;
    targetY = y;
    radius = maxRadius;
  }
  
  PVector getCenter() {
    return new PVector(startX, startY);
  }
  
  float getRadius() {
    return radius;
  }

  // Funzione che verifica se il cerchio tocca una corda
  boolean isTouchingCorda(Corda corda) {
    // Calcoliamo la distanza minima tra il cerchio e la corda
    float cordaX = corda.x;
    float cordaY = corda.y;
    float angolo = corda.angolo;
    
    // Proiettiamo la posizione del cerchio sulla corda
    float proiezioneX = cos(angolo) * (startX - cordaX) + sin(angolo) * (startY - cordaY);
    float proiezioneY = -sin(angolo) * (startX - cordaX) + cos(angolo) * (startY - cordaY);
    
    // Verifichiamo se il cerchio è vicino alla corda
    return abs(proiezioneY) < radius; // Il cerchio tocca la corda se la sua distanza dalla corda è inferiore al raggio
  }

  // Funzione che restituisce la direzione del movimento del cerchio
  float getDirection() {
    float direction = startX - prevX; // Calcoliamo la direzione in base alla posizione precedente
    prevX = startX; // Aggiorniamo la posizione precedente
    return direction > 0 ? 1 : -1; // Restituiamo 1 per destra, -1 per sinistra
  }
} // Fine della classe HandCircle
