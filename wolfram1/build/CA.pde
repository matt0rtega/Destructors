class CA {

  int[] cells; // An array of 0s and 1s
  int generation; // How many generations?

  int[] ruleset = {0, 0, 1, 0, 0, 1, 0, 1}; // An array to store the ruleset, for example {0,1,1,0,1,1,0,1}

  int w = 10;

  CA() {
    cells = new int[width/w];
    for (int i=0; i < cells.length; i++){
      cells[i] = 0;
    }

    cells[cells.length/2] = 1; // We arbitrarily start with just the middle cell having a state of "1"
    generation = 0;
  }

  void generate() {

    if(frameCount % 1 == 0){
    // First we create an empty array for the new values
    int[] nextgen = new int[cells.length];
    // For every spot, determine new state by examing current state, and neighbor states
    // Ignore edges that only have one neighor
    for (int i = 1; i < cells.length-1; i++) {
      int left = cells[i-1];   // Left neighbor state
      int me = cells[i];       // Current state
      int right = cells[i+1];  // Right neighbor state
      nextgen[i] = rules(left, me, right); // Compute next generation state based on ruleset
    }
    // The current generation is the new generation
    cells = nextgen;
    generation++;
      //createRandomRuleset();

    }


    println(generation);

    if(generation > 39){
      generation = 0;
      createRandomRuleset();
    }
  }

  void createRandomRuleset(){
    for(int i=0; i<ruleset.length; i++){
      ruleset[i] = (int)random(0, 2);
    }

    println("Ruleset created");
    printArray(ruleset);
  }

  // This is the easy part, just draw the cells, fill 255 for '1', fill 0 for '0'
  void display(PImage img) {

    //img.loadPixels();

    for (int i=0; i<cells.length; i++){
      color co = img.get(i*w, generation*w);
      float sat = saturation(co);

      if (cells[i] == 1) fill(co);
      else fill(255, 255, 255);
      noStroke();
      // Generation is equal to y in this 1-d CA
      rect(i*w, generation*w, w, w);
    }

  }

  // Implementing the Wolframe rules
  // Could be improved and made more concise
  int rules(int a, int b, int c){
    if (a == 1 && b == 1 && c == 1) return ruleset[0];
    if (a == 1 && b == 1 && c == 0) return ruleset[1];
    if (a == 1 && b == 0 && c == 1) return ruleset[2];
    if (a == 1 && b == 0 && c == 0) return ruleset[3];
    if (a == 0 && b == 1 && c == 1) return ruleset[4];
    if (a == 0 && b == 1 && c == 0) return ruleset[5];
    if (a == 0 && b == 0 && c == 1) return ruleset[6];
    if (a == 0 && b == 0 && c == 0) return ruleset[7];
    return 0;
  }

}
