import processing.video.*;
import gab.opencv.*;
import java.awt.*;

OpenCV opencv;

GOL gol;
PImage img;
PImage backgroundimg;

int camWidth;
int camHeight;

Capture cam;
PImage opencvcam;


void setup() {
  size(1280, 720, P2D);
  pixelDensity(1);
  //frameRate(15);
  
  
  camWidth = 640/2;
  camHeight = 360/2;
  
  gol = new GOL(camWidth, camHeight);

  img = loadImage("img1.png");
  img.resize(camWidth, camHeight);
  backgroundimg = createImage(camWidth, camHeight, RGB);

  cam = new Capture(this, camWidth, camHeight);
  
  opencv = new OpenCV(this, camWidth, camHeight);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE); 
  
  //startCapture();
  
  cam.start();
  
}

void draw() {
  //background(255);
  
  opencvcam = cam;

  if (cam.available() == true) {
    cam.read();
  }

  opencv.loadImage(opencvcam);
  
  Rectangle[] faces = opencv.detect();
  println(faces.length, gol.prob);
  
  if(faces.length > 0 && gol.prob < 0.3){
    takeSnapshot();
    gol.resetProb();
  }

  //backgroundimg.resize(width, height);
  scale(4);
  image(backgroundimg, 0, 0);
  
  gol.generate();

  gol.display(img);
  image(cam, 5, 5, 80, 45);
  
}

// reset board when mouse is pressed
void mousePressed() {
  img = get();
  img.resize(camWidth, camHeight);
  backgroundimg = img;
  img = cam.get();
  //img.resize(width/2, height/2);
  //backgroundimg.resize(width/2, height/2);

  gol.resetProb();
  gol.init();
  
  //println(frameRate);
}

void takeSnapshot(){
  mousePressed();
  //count = 0;
}

void captureEvent(Capture c) {
  c.read();
}

void startCapture(){
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

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[4]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);

    // Start capturing the images from the camera
    cam.start();
  }
}