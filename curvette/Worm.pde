class Worm {
  PVector pos;
  PVector target;
  PVector velocity;
  float speed = 2;     
  float turnSpeed = 0.1;
  int start_time;
  int elapsed;
  int grey;
  
  // constructor
  Worm() {
    pos = new PVector((float)random(width),(float)random(height));
    target = new PVector((float)random(width),(float)random(height));
    velocity = new PVector(0, 0);
    start_time = millis();
    elapsed = (int)random(300,1500);
    grey = (int)random(200,256);
  }
  
  // methods
  void display() {
    fill(0, 0, 0, 200);
    noStroke();
    ellipse(pos.x, pos.y, 5, 5);
  }
  
  void update() {
    int current = millis();
  
    if ((current - start_time) > elapsed) {
      target.set((float)random(width),(float)random(height));
      start_time = current;
      elapsed = (int)random(300,1500);
    }
    
    PVector desired = PVector.sub(target, pos);
    desired.setMag(speed); // Imposta la velocità massima

    // Interpolazione tra la direzione attuale e quella desiderata
    velocity.lerp(desired, turnSpeed);
  
    // Aggiorna la posizione
    pos.add(velocity);
    display();
  }
}
