PVector pos;         // Posizione del cerchietto
PVector target;      // Posizione target
PVector velocity;    // Direzione interpolata
float speed = 5;     // Velocità massima
float turnSpeed = 0.1; // Quanto velocemente curva
int t;

void setup() {
  size(800, 600);
  pos = new PVector(width / 2, height / 2);
  target = new PVector(mouseX, mouseY);
  velocity = new PVector(0, 0);
  t = millis();
}

void draw() {
  set_background(255,255,255,10);
  
  // Aggiorna il target con la posizione del mouse
  //target.set(mouseX, mouseY);
  int current = millis();
  
  if ((current - t) > 500) {
    target.set((float)random(width),(float)random(height));
    t = current;
  }
  
  // Calcola la direzione verso il target
  PVector desired = PVector.sub(target, pos);
  desired.setMag(speed); // Imposta la velocità massima

  // Interpolazione tra la direzione attuale e quella desiderata
  velocity.lerp(desired, turnSpeed);
  
  // Aggiorna la posizione
  pos.add(velocity);

  // Disegna il cerchio
  fill(255, 0, 0);
  noStroke();
  ellipse(pos.x, pos.y, 20, 20);
}

void set_background(int r, int g, int b, int a) {
  noStroke();
  fill(r, g, b, a);
  rect(0, 0, width, height);
}
