import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class build extends PApplet {

// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// A basic implementation of John Conway's Game of Life CA
// how could this be improved to use object oriented programming?
// think of it as similar to our particle system, with a "cell" class
// to describe each individual cell and a "cellular automata" class
// to describe a collection of cells



GOL gol;
PImage img;
PImage backgroundimg;

int count = 1;

Capture cam;

public void setup() {
  
  
  //frameRate(15);
  gol = new GOL();

  img = loadImage("img1.png");
  img.resize(width, height);
  backgroundimg = createImage(width, height, RGB);

  startCapture();
}

public void draw() {
  //background(255);

  if (cam.available() == true) {
    cam.read();
  }


  image(backgroundimg, 0, 0);

  if(frameCount % 2 == 0){
    gol.generate();
  }
  gol.display(img);

  image(cam, 20, height-200, 80, 45);
}

// reset board when mouse is pressed
public void mousePressed() {
  img = get();
  backgroundimg = img;
  img = cam.get();
  img.resize(width, height);

  gol.init();
}

public void startCapture(){
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 320, 180);
  } if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[0]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);

    // Start capturing the images from the camera
    cam.start();
  }
}

class GOL {
  int w = 2;
  int columns, rows;

  // Game of life board
  int[][] board;

  GOL() {
    columns = width/w;
    rows = height/w;
    board = new int[columns][rows];
    // Call function to fill array with random values 0 or 1
    init();

    noiseDetail(2, 0.6f);
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
        if      ((board[x][y] != 1) && (neighbors > 3)) next[x][y] = 1; // Loniliness
        else if ((board[x][y] == 0) && (neighbors > 4)) next[x][y] = 1; // Overpopulation
        //else if ((board[x][y] == 0) && (neighbors == 3)) next[x][y] = 1; // Reproduction
        else    next[x][y] = board[x][y];  // Stasis
      }
    }

    board = next;
  }

  public void display(PImage img) {



    for (int i=0; i<columns; i++){
      
      for (int j=0; j<rows; j++){
        float co = map(noise(i * 0.02f, j * 0.01f), 0, 1, 0, 255);

        if ((board[i][j] == 1)) fill(co, 0);
        else fill(img.get(i*w, j*w));
        //stroke(0);
        noStroke();
        rect(i*w, j*w, w, w);
      }
    }
  }

}
  public void settings() {  size(640, 360, P2D);  pixelDensity(1); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "build" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
