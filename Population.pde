class Population {
  private SmartSnake[] snakes;
  private int alive, highscore, generation;
  private SmartSnake best, showing;
  
  private float[] fitness;
  private float fitnessSum, bestFitness;
  
  private boolean newRecord, newFitness;
  
  public Population(int size) {
  	snakes = new SmartSnake[size];
    for (int i = 0; i < size; i++)
  	  snakes[i] = new SmartSnake(i+1);
  
    fitness = new float[size];
  	generation = 1;
  }
  
  public Population(SerializablePopulation serialPeople) {
    snakes = new SmartSnake[serialPeople.brains.length];
    for (int i = 0; i < snakes.length; i++) {
      Model brain = new Model(serialPeople.brains[i]);
      snakes[i] = new SmartSnake(i+1, brain);
    }
      
    generation = serialPeople.generation;
    fitness = new float[snakes.length];
  }
  
  public void reset() {
    for (Snake snake : snakes)
      snake.reset();
    best = snakes[0];
  }
  
  public void update() {
    if (showing == null)
      showing = snakes[0];
      
    alive = 0;
  	for (SmartSnake snake : snakes) {
  	  snake.scene.update();
  	  snake.update();
  
      if (snake.score > highscore) {
        highscore = snake.score;
        newRecord = true;
        showing = snake;
      }
  		
  	  if (snake.isAlive()) {
  		  alive++;
        if (snake.score > best.score)
          best = snake;
          
        if (snake.score > showing.score)
          showing = snake;
      }
  	}
  	
  	if (alive == 0) {
      calculateFitness();
      updateAndSaveProgress();
  	  reproduce();
      reset();
      showing = null;
  	  newRecord = false;
  	}
  }
  
  private void updateAndSaveProgress() {
    updateStats();
    Serializer.save(peoplePath, serialize());
    
    Champion champ = (Champion) Serializer.load(championPath);
    if (champ == null || best.score > champ.score) {
      SerializableModel brain = best.brain.serialize();
      champ = new Champion(brain, best.score, best.fitness());
      Serializer.save(championPath, champ);
    }
  }
  
  private SerializablePopulation serialize() {
    SerializableModel[] serialBrains = new SerializableModel[snakes.length];
    for (int i = 0; i < snakes.length; i++)
      serialBrains[i] = snakes[i].brain.serialize();
    return new SerializablePopulation(serialBrains, generation);
  }
  
  private void registerChild(SmartSnake[] snakes, int idx, SmartSnake child) {
    child.mutate(mutationRate);
    snakes[idx] = child;
  }
  
  private void reproduce() {
  	SmartSnake[] newGen = new SmartSnake[snakes.length];
  	for (int i = 0; i < snakes.length/2; i++) {
      int idx = i*2;
      SmartSnake[] children = crossover(pickOne(), pickOne(), idx+1, idx+2);
      registerChild(newGen, idx, children[0]);
      registerChild(newGen, idx+1, children[1]);
    }
  	
  	snakes = newGen;
  	generation++;
  }
  
  private void calculateFitness() {
  	fitnessSum = 0;
  	for (int i = 0; i < snakes.length; i++) {
  	  fitness[i] = snakes[i].fitness();
  	  fitnessSum += fitness[i];
  	}
  }
  
  private void updateStats() {
    float best = new Matrix(fitness).max();
    if (best > bestFitness) {
      bestFitness = best;
      newFitness = true;
    } else newFitness = false; 
  }
  
  private SmartSnake pickOne() {
  	float r = random(fitnessSum);
  	int index = 0;
  	while(r >= 0 && index < fitness.length)
  	  r -= fitness[index++];
  	return snakes[index-1];
  }
  
  public void showStats(float x, float y) {
    textAlign(LEFT, CENTER);
    fill(255);
    noStroke();
    textSize(18);
    
    if (newRecord) fill(255, 220, 0);
    text("HIGHSCORE: " + highscore, x, y);
    
    fill(255);
    text("ALIVE SNAKES: " + alive, x, y+25);
    
    if (newFitness) fill(0, 200, 0);
    else fill(255);
    text("BEST FITNESS: " + bestFitness, x, y+50);
    
    fill(255);
    text("GENERATION: " + generation, x, y+75);
  }
  
  public SmartSnake getShowing() {
    return showing;
  }
}
