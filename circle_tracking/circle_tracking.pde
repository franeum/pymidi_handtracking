float lastX, lastY;
float radius;
int previous_time;
float max_distance;

void setup() {
  size(1280, 960);
  frameRate(60);
  max_distance = dist(0,0,width/2, height/2);
  fullScreen(1);
}

void draw() {
  set_background();
  draw_circle(lastX, lastY, radius);
}

void set_background() {
  noStroke();
  fill(255,255,255,10);
  rect(0,0,width, height);
}

void draw_circle(float cx, float cy, float rad) {
  stroke(0,0,0);
  strokeWeight(2);
  circle(cx, cy, rad); 
}

void mouseMoved() {
  lastX = mouseX;
  lastY = mouseY;
  radius = dist(lastX, lastY, width / 2, height / 2);
  radius = map(radius, 0, max_distance, 200, 100);
}
