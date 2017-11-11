import processing.video.*;
import gab.opencv.*;
import java.awt.*;
import java.util.Calendar;

OpenCV opencv;

GOL gol;
PImage img;
PImage backgroundimg;

PImage[] collages;

String status = "";

int camWidth;
int camHeight;

Capture cam;
PImage opencvcam;
PGraphics canvas;

boolean displayPreview = true;

Rectangle[] faces;

PFont f;

void setup() {
  //size(540, 960, P3D);
  fullScreen(P3D);
  pixelDensity(1);

  camWidth = 960/2;
  camHeight = 540/2;

  // Create the font
  //printArray(PFont.list());
  f = createFont("Monospaced-24.vlw", 24);
  textFont(f);

  collages = new PImage[25];

  for(int i=0; i<collages.length; i++){
    collages[i] = loadImage("collage/img"+i+".png");
  }

  gol = new GOL(camWidth, camHeight);

  img = createImage(camWidth, camHeight, ARGB);
  img = loadImage("img1.png");
  img.resize(camWidth, camHeight);
  backgroundimg = createImage(camWidth, camHeight, ARGB);

  canvas = createGraphics(camHeight, camWidth);
  cam = new Capture(this, camWidth, camHeight);

  opencv = new OpenCV(this, camHeight, camWidth);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  checkCameras();

  cam.start();
}

void draw() {

  // Rotate Image
  opencvcam = rotateImage(cam, -90);

  if (cam.available() == true) {
    cam.read();
  }

  opencv.loadImage(opencvcam);

  faces = opencv.detect();
  //println(faces.length, gol.prob);

  if(faces.length > 0 && gol.prob < 0.5){
    gol.colorToggle = true;
    takeSnapshot();
    gol.reset();
  } else if(gol.prob < 0.1){
    gol.colorToggle = !gol.colorToggle;
    takeSnapshot();
    gol.reset();
  }

  pushMatrix();
  imageMode(CENTER);
  translate(width/2, height/2);
  rotate(radians(-90));
  scale(3.35);
  image(backgroundimg, 0, 0);
  gol.generate();
  gol.displayPixels(img);
  popMatrix();


  if (displayPreview){
    // Camera Preview
    pushMatrix();
    imageMode(CORNER);
    translate(0, height-opencv.height);
    drawFaces();
    image(opencvcam, 0, 0);
    
    text("Please wait...", width-(250), mouseY);
    popMatrix();
  }

  
}

void drawFaces(){

  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);

  for (int i = 0; i < faces.length; i++) {
    //println(faces[i].x + "," + faces[i].y);
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }

}

// reset board when mouse is pressed
void mousePressed() {

  displayPreview = false;

  img.resize(camWidth, camHeight);
  backgroundimg.resize(camWidth, camHeight);
  backgroundimg = img;

}

void mouseReleased(){

  exportFrame();

  img = cam.get();

  gol.reset();
  gol.init();
}

void status(){
  if (gol.prob > 0.6){
    status = "Please wait...";
  } else {
    status = "Ready.";
  }
}

void takeSnapshot(){
  mousePressed();
  mouseReleased();
}

void exportFrame(){

  displayPreview = false;

  PGraphics output = createGraphics(camWidth, camHeight, P2D);
  output.beginDraw();
  output.background(0,0,0,0);
  output.image(backgroundimg, 0, 0);
  output.image(img, 0, 0);
  output.endDraw();

  output.save("111017/bitrot"+timestamp()+"_3.png");
  saveFrame("111017/bitrot"+timestamp()+"_4.png");

  displayPreview = true;
}

void captureEvent(Capture c) {
  c.read();
}

void checkCameras(){
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 360);
  } if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

  }
}

void keyPressed(){

  if(key == 'c'){
    gol.changeImage();
  }

  if(key == 't'){
    gol.colorToggle = !gol.colorToggle;
    gol.reset();
  }

  if(key == 's'){
    mousePressed();
    mouseReleased();
  }

}

// Thank you Fabio Cionini design www.todo.to.it
//https://processing.org/discourse/beta/num_1215632756.html
PImage rotateImage(PImage img, int angle)
{
  PImage rot;
  int numPixels = img.height*img.width;
  if (abs(angle) == 180)
  {
    rot = new PImage(img.width,img.height);
  }
  else
  {
    rot = new PImage(img.height,img.width);
  }
  img.loadPixels();

  int rotpx = 0;
  for (int i = 0; i < numPixels; i++)
  {
      int x0 = i % img.width;
      int y0 = floor(i / img.width);

      // for each pixel calculates new x & y coordinates and index
      if (angle == 90)
      {
        int x1 = abs(y0 + 1 - img.height);
        int y1 = x0;
        rotpx = x1 + (y1 * rot.width);
      }
      else if (angle == -90 || angle == 270)
      {
        int x1 = y0;
        int y1 = abs(x0 + 1 - img.width);
        rotpx = x1 + (y1 * rot.width);
      }
      else if (angle == 180 || angle == -180)
      {
        // 180 is the easiest, just flip the array index...
        rotpx = numPixels - 1 - i;
      }
      else
      {
        // angles other than 90/180 are far more complicated...
        println("Not implemented, sorry :)");
      }

      rot.pixels[rotpx] = img.pixels[i];
  }
  rot.updatePixels();
  return rot;
}

String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}