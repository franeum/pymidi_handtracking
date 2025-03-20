int size = 10000;
Worm[] worms = new Worm[size];

void setup() {
  size(800, 800, P3D);
  for (int i=0; i<size; i++)
    worms[i] = new Worm();
  fullScreen(1);
}

void draw() {
  set_background(255,5);
  for (Worm w : worms)
    w.update();
}

void set_background(int w, int a) {
  noStroke();
  fill(w, a);
  rect(0, 0, width, height);
}
