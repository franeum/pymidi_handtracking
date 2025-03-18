import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

float radius;
int previous_time;
float max_distance;
float alpha = 0.3;
float startX, startY;
float targetX, targetY;

void setup() {
  size(1280, 960);
  frameRate(48);
  //max_distance = dist(0,0,width/2, height/2);
  oscP5 = new OscP5(this,12000);
  fullScreen(1);
}

void draw() {
  set_background();
  
  startX = alpha * targetX + (1 - alpha) * startX;
  startY = alpha * targetY + (1 - alpha) * startY;
  
  draw_circle(startX, startY, radius);
}

void set_background() {
  noStroke();
  fill(255,255,255,5);
  rect(0,0,width, height);
}

void draw_circle(float cx, float cy, float rad) {
  fill(0, 64);
  noStroke();
  circle(cx, cy, rad); 
}

void update(float x, float y, float z) {
  targetX = x;
  targetY = y;
  radius = 100.0;
}


void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/test")==true) {
    if(theOscMessage.checkTypetag("fff")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      float _x = theOscMessage.get(0).floatValue() * width;  
      float _y = theOscMessage.get(1).floatValue() * height;
      float _z = theOscMessage.get(2).floatValue() * 200;
      update(_x, _y, _z);
      return;
    }  
  } 
}
