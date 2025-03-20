float alpha = 0.25;
float easing = 0.02;

class HandCircle {
  float startX, startY;
  float targetX, targetY;
  float radius;
  
  // constructor
  HandCircle() {
    startX = width / 2;
    startY = height / 2;
    radius = 100;
  }
  
  // methods
  void update() {
    // lowpass filter
    //startX = alpha * targetX + (1 - alpha) * startX;
    //startY = alpha * targetY + (1 - alpha) * startY;
    
    float dx = targetX - startX;
    float dy = targetY - startY;
    
    startX += dx * easing;
    startY += dy * easing;
    
    display();    
  }
  
  void osc_update(float x, float y, float z) {
    targetX = x;
    targetY = y;
    radius = 100.0;
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
