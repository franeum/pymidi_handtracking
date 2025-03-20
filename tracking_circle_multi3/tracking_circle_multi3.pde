import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

HandCircle hc1;
HandCircle hc2;

float vibrationAmplitude = 0;  // Ampiezza attuale della vibrazione
float targetAmplitude = 10;    // Ampiezza massima della vibrazione
float vibrationFrequency = 2; // Frequenza della vibrazione
float currentPhase = 0;        // Fase attuale della vibrazione
float vibrationDecay = 0.98;   // Fattore di smorzamento dell'ampiezza (0.98 = 2% di riduzione per frame)

void setup() {
  size(1280, 960);
  frameRate(60);
  oscP5 = new OscP5(this, 12000);
  hc1 = new HandCircle();
  hc2 = new HandCircle();
  fullScreen(1);
}

void draw() {
  // Impostiamo lo sfondo bianco (senza trasparenza)
  background(255); 
  
  // Controlliamo se uno dei cerchi tocca la linea verticale centrale
  if (hc1.isTouchingVerticalLine()) {
    startVibration(hc1.getDirection());  // Iniziamo/riavviamo la vibrazione con la direzione del cerchio
  }
  
  if (hc2.isTouchingVerticalLine()) {
    startVibration(hc2.getDirection());  // Iniziamo/riavviamo la vibrazione con la direzione del cerchio
  }

  // Aggiorniamo i cerchi
  hc1.update(hc2.getCenter());  // Aggiorniamo hc1 rispetto a hc2
  hc2.update(hc1.getCenter());  // Aggiorniamo hc2 rispetto a hc1

  // Riduciamo gradualmente l'ampiezza della vibrazione
  vibrationAmplitude *= vibrationDecay;
  
  // Se l'ampiezza è molto piccola, la fermiamo
  if (vibrationAmplitude < 0.1) {
    vibrationAmplitude = 0;
  }

  // Disegniamo la corda vibrante come una linea modulata
  stroke(255, 0, 0);  // Linea rossa
  noFill();
  beginShape();
  for (int y = 0; y <= height; y += 10) {
    float yNorm = map(y, 0, height, 0, PI); // Normalizziamo Y tra 0 e PI
    float localAmplitude = sin(yNorm) * vibrationAmplitude; // Ampiezza modulata
    float offset = sin(currentPhase + yNorm) * localAmplitude;
    vertex(width / 2 + offset, y); // Aggiungiamo un punto alla forma
  }
  endShape();
  
  // Aggiorniamo la fase della vibrazione
  currentPhase += vibrationFrequency;
}

// Funzione per iniziare/riavviare la vibrazione della linea
void startVibration(float direction) {
  vibrationAmplitude = targetAmplitude; // Reimpostiamo l'ampiezza massima
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

class HandCircle {
  float startX, startY;
  float targetX, targetY;
  float radius;
  float maxRadius = 25.0;  // Raggio iniziale
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
    fill(0); // Assicurati che il cerchio sia disegnato correttamente
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

  // Funzione che verifica se il cerchio tocca la linea verticale
  boolean isTouchingVerticalLine() {
    // Verifica se la posizione X del cerchio è vicina alla posizione della linea centrale
    return abs(startX - width / 2) < radius; // Il cerchio tocca la linea se la sua distanza dalla linea è inferiore al raggio
  }

  // Funzione che restituisce la direzione del movimento del cerchio
  float getDirection() {
    float direction = startX - prevX; // Calcoliamo la direzione in base alla posizione precedente
    prevX = startX; // Aggiorniamo la posizione precedente
    return direction > 0 ? 1 : -1; // Restituiamo 1 per destra, -1 per sinistra
  }
}
