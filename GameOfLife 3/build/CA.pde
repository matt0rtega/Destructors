class GOL {
  int w = 1;
  int columns, rows;

  int counter = 0;

  float prob = 0.9;

  int colorSelector = 0;
  boolean colorToggle = true;
  color[] colors = {color(255, 0, 0), color(0, 0, 255), color(0, 255, 0), color(0, 255, 100)};

  // Game of life board
  int[][] board;

  GOL(int camWidth, int camHeight) {
    columns = camWidth/w;
    rows = camHeight/w;
    board = new int[columns][rows];
    // Call function to fill array with random values 0 or 1
    init();
  }

  void init() {
    for (int i=1; i<columns-1; i++){
      for(int j=1; j<rows-1; j++){

        if(random(1) > .1){
          board[i][j] = 0;
        } else {
          board[i][j] = 1;
        }
        //board[i][j] = int(random(2));
      }
    }
  }

  void update(){
    counter++;
  }

  // The process of creating the new generation
  void generate() {

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


    if(prob > 0.01){
      prob -= 0.002;
    }
  }

  void reset(){
    int randColor = (int)random(0, colors.length);

    if(randColor != colorSelector){
      colorSelector = randColor;
    } else {
      randColor = (int)random(0, colors.length);
      colorSelector = randColor;
    }

    prob = 0.9;
  }

  void display(PImage img) {

    for (int i=0; i<columns; i++){
      for (int j=0; j<rows; j++){
        float co = map(noise(i * 0.02, j * 0.01), 0, 1, 0, 255);

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

  void displayPixels(PImage img) {

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
