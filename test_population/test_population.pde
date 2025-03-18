int size = 100;
float easing = 0.005;
HandCircle[] hc = new HandCircle[size];
int t;

void setup() {
  size(800,800);
  
  for (int i=0; i<size; i++) 
    hc[i] = new HandCircle();
  
  t = millis();
  fullScreen(1);
}

void draw() {
  set_background(255,255,255,10);
  
  int now = millis();
  
  /*
  if ((now - t) > 2000) {
    for (HandCircle _hc : hc) 
      _hc.osc_update((float)random(width), (float)random(height), 20);
    t = now;
  }
  */
  
  for (HandCircle _hc : hc)
    _hc.update();
}


void set_background(int r, int g, int b, int a) {
  noStroke();
  fill(r, g, b, a);
  rect(0, 0, width, height);
}

class HandCircle {
  float startX, startY;
  float targetX, targetY;
  float radius;
  int last_time;
  int elapsed;
  
  // constructor
  HandCircle() {
    startX = width / 2;
    startY = height / 2;
    radius = 20;
    last_time = millis();
    elapsed = (int)random(1000,2000);
  }
  
  // methods
  void update() {
    int current_time = millis();
    
    if ((current_time - last_time) >= elapsed) {
      targetX = (float)random(width);
      targetY = (float)random(height);
      last_time = current_time;
      elapsed = (int)random(1000,2000);
    }
    
    float dx = targetX - startX;
    float dy = targetY - startY;
    
    startX += dx * easing;
    startY += dy * easing;
    
    display();    
  }
  
  void osc_update(float x, float y, float z) {
    targetX = x;
    targetY = y;
    radius = z;
  }
  
  void display() {
    fill(0, 32);
    noStroke();
    circle(startX, startY, radius);
  }
  
  PVector getCenter() {
    PVector center;
    center = new PVector(startX, startY);
    return center;
  }
  
  float getRadius() {
    return radius;
  }
}
