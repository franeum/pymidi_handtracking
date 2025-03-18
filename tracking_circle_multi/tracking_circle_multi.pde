import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

HandCircle hc1;
HandCircle hc2;

void setup() {
  size(1280, 960);
  frameRate(60);
  //max_distance = dist(0,0,width/2, height/2);
  oscP5 = new OscP5(this,12000);
  hc1 = new HandCircle();
  hc2 = new HandCircle();
  fullScreen(1);
}

void draw() {
  PVector center1 = hc1.getCenter();
  PVector center2 = hc2.getCenter();
  
  float _dist = dist(center1.x, center1.y, center2.x, center2.y);
  
  if (_dist < 100)
    set_background(255,0,0,10);
  else
  set_background(255,255,255,10);
  hc1.update();
  hc2.update();
}

void set_background(int r, int g, int b, int a) {
  noStroke();
  fill(r, g, b, a);
  rect(0, 0, width, height);
}


void oscEvent(OscMessage msg) {
  if(msg.checkAddrPattern("/left") == true) {
    if(msg.checkTypetag("fff")) {
        float _x = msg.get(0).floatValue() * width;  
        float _y = msg.get(1).floatValue() * height;
        float _z = msg.get(2).floatValue() * 200;
        hc1.osc_update(_x, _y, _z); 
      }
      return;
    } else if (msg.checkAddrPattern("/right") == true) {
    if(msg.checkTypetag("fff")) {
        float _x = msg.get(0).floatValue() * width;  
        float _y = msg.get(1).floatValue() * height;
        float _z = msg.get(2).floatValue() * 200;
        hc2.osc_update(_x, _y, _z);   
    }
    return;
  }
} 
