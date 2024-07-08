class Population {
  private Snake[] snakes;
  private int alive, generation, highscore;
  
  private float[] fitness;
  private float fitnessSum, bestFitness;
  
  private boolean newRecord, newFitness;
  
  public Population(int size) {
    snakes = new Snake[size];
    for (int i = 0; i < size; i++)
      snakes[i] = new Snake();
      
    generation = 1;
    fitness = new float[size];
  }
  
  public void update() {
    alive = 0;
    for (Snake snake : snakes) {
      snake.scene.update();
      snake.update();
        
      if (snake.isAlive())
        alive++;
    }
    
    if (snakes[0].score > highscore) {
      highscore = snakes[0].score;
      newRecord = true;
    }
    
    if (alive == 0) {
      reproduce();
      newRecord = false;
    }
  }
  
  private void reproduce() {
    calculateFitness();
    
    int bestIndex = findBest();
    if (fitness[bestIndex] > bestFitness) {
      bestFitness = fitness[bestIndex];
      newFitness = true;
    } else newFitness = false;
    
    Snake[] newGen = new Snake[snakes.length];
    newGen[0] = snakes[bestIndex];
    newGen[0].reset(true);
    for (int i = 1; i < snakes.length; i++) {
      newGen[i] = pickOne().crossover(pickOne());
      newGen[i].mutate(mutationRate);
    }
    
    snakes = newGen;
    generation++; //<>//
  }
  
  private void calculateFitness() {
    fitnessSum = 0;
    for (int i = 0; i < snakes.length; i++) {
      fitness[i] = snakes[i].fitness();
      fitnessSum += fitness[i];
    }
  }
  
  private int findBest() {
    return new Matrix(fitness).argmax();
  }
  
  private Snake pickOne() {
    float r = random(fitnessSum);
    int index = 0;
    while(r >= 0 && index < fitness.length)
      r -= fitness[index++];
    return snakes[index-1];
  }
  
  public void showBest(float x, float y) {
    snakes[0].scene.show(x, y);
  }
  
  public void showStats(float x, float y) {
    textAlign(LEFT, CENTER);
    fill(255);
    noStroke();
    
    textSize(36);
    text("SCORE: " + snakes[0].score, x, y);
    
    textSize(18);
    
    if (newRecord) fill(255, 220, 0);
    text("HIGHSCORE: " + highscore, x, y+45);
    
    if (snakes[0].steps == 0) fill(255, 0, 0);
    else if (snakes[0].steps < 100) fill(255, 150, 0);
    else fill(255);
    text("LEFT MOVES: " + snakes[0].steps, x, y+70);
    
    fill(255);
    text("ALIVE SNAKES: " + alive, x, y+95);
    
    if (newFitness) fill(0, 200, 0);
    else fill(255);
    text("BEST FITNESS: " + bestFitness, x, y+120);
    
    fill(255);
    text("GENERATION: " + generation, x, y+145);
  }
  
  public void showBrain(float x, float y, float scale) {
    int[] nodes = snakes[0].brain.layers;
    Matrix[] weights = snakes[0].brain.weights;
    
    float layersGap = 120*scale;
    float nodesGap = 25*scale;
    float h = 23*nodesGap;
    float nodeRadius = 15*scale;
    float textSize = 14*(scale+0.1);
    
    Matrix[] outputs = new Matrix[nodes.length];
    outputs[0] = snakes[0].brain.input;
    for (int i = 1; i < nodes.length-1; i++)
      outputs[i] = new Matrix(nodes[i], 1);
      
    Matrix output = new Matrix(nodes[nodes.length-1], 1);
    output.set(snakes[0].brain.output.argmax(), 0, 1);
    outputs[nodes.length-1] = output;
    
    String[] inLabels = {"E", "NE", "N", "NO", "O"};
    String[] outLabels = {"RIGHT", "FORWARD", "LEFT"};
    textSize(textSize);
    for (int i = 0; i < nodes.length; i++) {
      float centerY = y+h/2;
      for (int j = 0; j < nodes[i]; j++) {
        float nodeX = x+i*layersGap;
        float nodeY = centerY-nodesGap*(nodes[i]/2-j);
        if (i == 0 && j%3 == 0) {
          textAlign(RIGHT, CENTER);
          fill(255);
          text(inLabels[j/3], nodeX-20, nodeY);
        } else if (i == nodes.length-1) {
          textAlign(LEFT, CENTER);
          fill(255);
          text(outLabels[j], nodeX+20, nodeY);
        }
        
        if (i < nodes.length-1)
          for (int k = 0; k < nodes[i+1]; k += 3) {
            int index = constrain(k+j%3, 0, nodes[i+1]-1);
            float value = weights[i].get(j, index);
            if (value >= 0) 
              stroke(0, 0, 150);
            else stroke(150, 0, 0);
            strokeWeight(map(abs(value), 0, 1, 1, 3));
            line(nodeX, nodeY, nodeX+layersGap, centerY-nodesGap*(nodes[i+1]/2-index));
          }
      }
      
      noStroke();
      for (int j = 0; j < nodes[i]; j++) {
        float nodeX = x+i*layersGap;
        float nodeY = centerY-nodesGap*(nodes[i]/2-j);
        if (outputs[i].get(j, 0) >= 0.5)
          fill(0, 255, 0);
        else fill(255);
        circle(nodeX, nodeY, nodeRadius);
      }
    }
  }
}
