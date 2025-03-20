import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

HandCircle hc1;
HandCircle hc2;

void setup() {
  size(1280, 960);
  frameRate(60);
  oscP5 = new OscP5(this, 12000);
  hc1 = new HandCircle();
  hc2 = new HandCircle();
  fullScreen(1);
}

void draw() {
  PVector center1 = hc1.getCenter();
  PVector center2 = hc2.getCenter();
  
  // Calcoliamo la distanza tra i due cerchi
  float _dist = dist(center1.x, center1.y, center2.x, center2.y);
  
  // Applichiamo un colore di sfondo a seconda della distanza tra i cerchi
  if (_dist < 100) 
    set_background(255, 0, 0, 10);  // Colore rosso quando sono vicini
  else 
    set_background(255, 255, 255, 10);  // Colore bianco altrimenti
  
  hc1.update(center2, _dist);  // Aggiorniamo hc1 rispetto a hc2
  hc2.update(center1, _dist);  // Aggiorniamo hc2 rispetto a hc1
}

void set_background(int r, int g, int b, int a) {
  noStroke();
  fill(r, g, b, a);
  rect(0, 0, width, height);
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
  float minRadius = 10.0;   // Raggio minimo per evitare che spariscano
  float distanceThreshold = 100; // Distanza minima per evitare il contatto
  float moveSpeed = 0.05;  // Velocità del movimento

  HandCircle() {
    startX = width / 2;
    startY = height / 2;
    targetX = startX;
    targetY = startY;
    radius = maxRadius;
  }
  
  void update(PVector otherCenter, float distance) {
    // Calcoliamo la distanza tra i cerchi
    float dx = targetX - startX;
    float dy = targetY - startY;
    
    // Aggiorniamo il movimento del cerchio (spostamento graduale)
    startX += dx * moveSpeed;
    startY += dy * moveSpeed;
    
    // Calcoliamo la distanza tra i cerchi
    float distBetween = dist(startX, startY, otherCenter.x, otherCenter.y);
    
    // Se la distanza tra i cerchi è inferiore alla somma dei loro raggi, li separiamo
    if (distBetween < 2 * radius) {
      // Calcoliamo l'angolo tra i centri dei cerchi
      float angle = atan2(startY - otherCenter.y, startX - otherCenter.x);
      
      // Calcoliamo la separazione necessaria per evitare la sovrapposizione
      float overlap = 2 * radius - distBetween;  // Sovrapposizione dei cerchi
      float separation = overlap * 0.5;  // Separazione elastica
      
      // Separiamo i cerchi lungo la direzione dell'angolo
      startX += cos(angle) * separation;
      startY += sin(angle) * separation;
      targetX += cos(angle) * separation;
      targetY += sin(angle) * separation;
    }
    
    // Disegniamo il cerchio come un cerchio perfetto
    fill(0, 32);
    noStroke();
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
}
