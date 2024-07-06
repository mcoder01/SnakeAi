class Population {
  private Snake[] snakes;
  private int alive, generation, highscore;
  private float bestFitness;
  
  public Population(int size) {
    snakes = new Snake[size];
    for (int i = 0; i < size; i++)
      snakes[i] = new Snake();
    generation = 1;
  }
  
  public void update() {
    alive = 0;
    for (Snake snake : snakes) {
      snake.scene.update();
      snake.update();
      if (snake.score > highscore)
        highscore = snake.score;
        
      if (snake.isAlive())
        alive++;
    }
    
    if (alive == 0)
      reproduce();
  }
  
  private void reproduce() {
    float[] fitness = calcFitness();
    int bestIndex = findBest(fitness);
    Snake best = snakes[bestIndex];
    bestFitness = fitness[bestIndex];
    
    Snake[] newGen = new Snake[snakes.length];
    newGen[0] = best;
    newGen[0].reset(true);
    for (int i = 1; i < snakes.length; i++) {
      Snake mother = pickOne(fitness);
      Snake father = pickOne(fitness);
      newGen[i] = mother.crossover(father);
      newGen[i].mutate(0.1);
    }
    
    snakes = newGen;
    generation++; //<>//
  }
  
  private float[] calcFitness() {
    float[] fitness = new float[snakes.length];
    for (int i = 0; i < snakes.length; i++)
      fitness[i] = snakes[i].fitness();
    return fitness;
  }
  
  private int findBest(float[] fitness) {
    return new Matrix(fitness).argmax();
  }
  
  private Snake pickOne(float[] fitness) {
    float sum = 0;
    for (float f : fitness)
      sum += f;
      
    float r = random(sum);
    int index = 0;
    while(r >= 0)
      r -= fitness[index++];
    return snakes[index-1];
  }
  
  public void showBest() {
    snakes[0].scene.show(0, 0);
    
    textAlign(LEFT, CENTER);
    textSize(22);
    text("Score: " + snakes[0].score, width-280, 30);
    text("Highscore: " + highscore, width-280, 70);
    text("Steps: " + snakes[0].steps, width-280, 110);
    text("Alive: " + alive, width-280, 150);
    text("Best fitness: " + bestFitness, width-280, 190);
    text("Generation: " + generation, width-280, 230);
  }
}
