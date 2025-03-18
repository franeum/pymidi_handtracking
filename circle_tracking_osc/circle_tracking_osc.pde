import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

float lastX, lastY;
float radius;
int previous_time;
float max_distance;

void setup() {
  size(1280, 960);
  frameRate(30);
  max_distance = dist(0,0,width/2, height/2);
  oscP5 = new OscP5(this,12000);
  fullScreen(1);
}

void draw() {
  set_background();
  draw_circle(lastX, lastY, radius);
}

void set_background() {
  noStroke();
  fill(255,255,255,5);
  rect(0,0,width, height);
}

void draw_circle(float cx, float cy, float rad) {
  noFill();
  stroke(0,0,0);
  strokeWeight(1);
  circle(cx, cy, rad); 
}

void update(float x, float y, float z) {
  lastX = x;
  lastY = y;
  //radius = dist(lastX, lastY, width / 2, height / 2);
  //radius = map(radius, 0, max_distance, 200, 100);
  radius = z;
}


void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  
  if(theOscMessage.checkAddrPattern("/test")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("fff")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      float firstValue = theOscMessage.get(0).floatValue() * width;  
      float secondValue = theOscMessage.get(1).floatValue() * height;
      float depth = theOscMessage.get(2).floatValue() * 200;
      update(firstValue, secondValue, depth);
      print("### received an osc message /test with typetag ifs.");
      //println(" values: "+firstValue+", "+secondValue+");
      println(firstValue);
      println(secondValue);
      return;
    }  
  } 
  //println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
}
