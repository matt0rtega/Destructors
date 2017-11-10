import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import gab.opencv.*; 
import java.awt.*; 
import java.util.Calendar; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class build extends PApplet {






OpenCV opencv;

GOL gol;
PImage img;
PImage backgroundimg;

int camWidth;
int camHeight;

Capture cam;
PImage opencvcam;
PGraphics canvas;

boolean displayPreview = true;

Rectangle[] faces;

public void setup() {
  
  //fullScreen(P3D);
  

  camWidth = 960/2;
  camHeight = 540/2;

  orientation(PORTRAIT);

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

public void draw() {

  // Rotate Image
  opencvcam = rotateImage(cam, -90);

  if (cam.available() == true) {
    cam.read();
  }

  opencv.loadImage(opencvcam);

  faces = opencv.detect();
  //println(faces.length, gol.prob);



  if(faces.length > 0 && gol.prob < 0.5f){
    gol.colorToggle = true;
    takeSnapshot();
    gol.reset();
  } else if(gol.prob < 0.1f){
    gol.colorToggle = !gol.colorToggle;
    takeSnapshot();
    gol.reset();
  }

  //backgroundimg.resize(width, height);

  // imageMode(CENTER);
  // translate(mouseX, mouseY);
  // rotate(radians(-90));
  //scale(2);
  //image(backgroundimg, 0, 0);
  pushMatrix();
  imageMode(CENTER);
  translate(width/2, height/2);
  rotate(radians(-90));
  scale(2);
  image(backgroundimg, 0, 0);
  gol.generate();
  gol.displayPixels(img);
  popMatrix();


  if (displayPreview){
    // Feed
    pushMatrix();
    imageMode(CORNER);
    translate(0, height-opencv.height);
    drawFaces();
    image(opencvcam, 0, 0);
    popMatrix();
  }

}

public void showImagev1(){

}

public void drawFaces(){
  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);

  for (int i = 0; i < faces.length; i++) {
    //println(faces[i].x + "," + faces[i].y);
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
}

// reset board when mouse is pressed
public void mousePressed() {
  //exportFrame();

  displayPreview = false;

  img.resize(camWidth, camHeight);
  backgroundimg.resize(camWidth, camHeight);
  backgroundimg = img;


  //println(frameRate);
}

public void mouseReleased(){

  exportFrame();

  img = cam.get();
  //img.resize(width/2, height/2);
  //backgroundimg.resize(width/2, height/2);


  gol.reset();
  gol.init();
}

public void takeSnapshot(){
  mousePressed();
  mouseReleased();
  //count = 0;
}

public void exportFrame(){

  displayPreview = false;

  PGraphics output = createGraphics(camWidth, camHeight, P2D);
  output.beginDraw();
  output.background(0,0,0,0);
  output.image(backgroundimg, 0, 0);
  output.image(img, 0, 0);
  output.endDraw();

  // img.save("111017/bitrot"+timestamp()+"_0.png");
  // backgroundimg.save("111017/bitrot"+timestamp()+"_1.png");
  output.save("111017/bitrot"+timestamp()+"_3.png");
  saveFrame("111017/bitrot"+timestamp()+"_4.png");

  displayPreview = true;
}

public void captureEvent(Capture c) {
  c.read();
}

public void checkCameras(){
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

public void keyPressed(){
  boolean toggleState = gol.colorToggle;
  gol.colorToggle = !toggleState;

  mousePressed();
  mouseReleased();
}

// Thank you Fabio Cionini design www.todo.to.it
//https://processing.org/discourse/beta/num_1215632756.html
public PImage rotateImage(PImage img, int angle)
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

public String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}
class GOL {
  int w = 1;
  int columns, rows;

  int counter = 0;

  float prob = 0.9f;

  int colorSelector = 0;
  boolean colorToggle = true;
  int[] colors = {color(255, 0, 0), color(0, 0, 255), color(0, 255, 0), color(0, 255, 100)};

  // Game of life board
  int[][] board;

  GOL(int camWidth, int camHeight) {
    columns = camWidth/w;
    rows = camHeight/w;
    board = new int[columns][rows];
    // Call function to fill array with random values 0 or 1
    init();
  }

  public void init() {
    for (int i=1; i<columns-1; i++){
      for(int j=1; j<rows-1; j++){

        if(random(1) > .1f){
          board[i][j] = 0;
        } else {
          board[i][j] = 1;
        }
        //board[i][j] = int(random(2));
      }
    }
  }

  public void update(){
    counter++;
  }

  // The process of creating the new generation
  public void generate() {

    int[][] next = new int[columns][rows];

    // Loop through every spot in our 2D array and check spots neighbors
    for (int x=1; x<columns-1; x++){
      for(int y=1; y<rows-1; y++){

        // Add up all the states in a 3x3 surrounding grid
        int neighbors = 0;
        for (int i=-1; i<= 1; i++){
          for (int j=-1; j<= 1; j++){
            neighbors += board[x+i][y+j];
          }
        }

        // A little trick to subtract the current cell's state since
        // we added it in the above loop
        neighbors -= board[x][y];

        // Rules of life
        // == 6 and > 2 interesting setting
        if      ((board[x][y] == 0) && (neighbors > 4) && random(1)<prob) next[x][y] = 1; // Loniliness
        // Realized that this was repetitive
        else if ((board[x][y] == 0) && (neighbors > 3) && random(1)<prob) next[x][y] = 1; // Overpopulation
        //else if ((board[x][y] == 0) && (neighbors == 3)) next[x][y] = 1; // Reproduction
        else    next[x][y] = board[x][y];  // Stasis
      }
    }

    board = next;


    if(prob > 0.01f){
      prob -= 0.002f;
    }
  }

  public void reset(){
    int randColor = (int)random(0, colors.length);

    if(randColor != colorSelector){
      colorSelector = randColor;
    } else {
      randColor = (int)random(0, colors.length);
      colorSelector = randColor;
    }

    prob = 0.9f;
  }

  public void display(PImage img) {

    for (int i=0; i<columns; i++){
      for (int j=0; j<rows; j++){
        float co = map(noise(i * 0.02f, j * 0.01f), 0, 1, 0, 255);

        if ((board[i][j] == 1)) fill(0, 0);
        //Kind of cool
        //if ((board[i][j] == 1)) img.set(i*w, j*w, 0);
        else fill(img.get(i*w, j*w));
        //stroke(0);
        noStroke();
        rect(i*w, j*w, w, w);
      }
    }
  }

  public void displayPixels(PImage img) {

    img.loadPixels();
    for (int x=1; x<columns-1; x++){
      for (int y=1; y<rows-1; y++){

        int loc = x + y * img.width;

        // Add up all the states in a 3x3 surrounding grid
        int neighbors = 0;
        for (int i=-1; i<= 1; i++){
          for (int j=-1; j<= 1; j++){
            neighbors += board[x+i][y+j];
          }
        }

        if ((board[x][y] == 1)) {
          if(colorToggle){
            if ((board[x][y] == 1)) img.pixels[loc] = color(img.pixels[loc], 0);
          } else {
            if ((board[x][y] == 1)) img.pixels[loc] = colors[colorSelector];
          }
        }


        //Kind of cool
        //if ((board[i][j] == 1)) img.set(i*w, j*w, 0);
        else img.pixels[loc] = img.pixels[loc];
      }
    }

    img.updatePixels();

    image(img, 0, 0);
  }

}
  public void settings() {  size(540, 960, P3D);  pixelDensity(1); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "build" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
