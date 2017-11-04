CA ca;

// Make colors come from PImage
PImage img;

void setup() {
  size(800, 400);
  background(255);
  ca = new CA();

  img = loadImage("img1.png");

  img.resize(width, height);
}

void draw() {
  fill(255, 25);
  rect(0, 0, width, height);

  ca.display(img);
  if (ca.generation < height/ca.w){
    ca.generate();
  }
}
