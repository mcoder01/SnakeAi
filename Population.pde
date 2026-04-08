class Population {
  private SmartSnake[] snakes;
  private int alive, generation, highscore;
  private SmartSnake showing;
  
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
    snakes = new SmartSnake[serialPeople.snakes.length];
    for (int i = 0; i < snakes.length; i++)
      snakes[i] = new SmartSnake(serialPeople.snakes[i]);
      
    highscore = serialPeople.highscore;
    bestFitness = serialPeople.bestFitness;
    generation = serialPeople.generation;
    fitness = new float[snakes.length];
  }
  
  private String nextData(BufferedReader reader, String def) {
    try {
      return reader.readLine().split("=")[1];
    } catch(IOException e) {
      return def;
    }
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
        if (!showing.isAlive() && snake.score > showing.score)
          showing = snake;
      }
  	}
  	
  	if (alive == 0) {
      calculateFitness();
      updateStats();
      saveProgress();
  	  reproduce();
      showing = null;
  	  newRecord = false;
  	}
  }
  
  private void updateStats() {
    int best = findBest();
    updateStats(best);
  }
  
  private SerializablePopulation serialize() {
    SerializableSnake[] serialSnakes = new SerializableSnake[snakes.length];
    for (int i = 0; i < snakes.length; i++)
      serialSnakes[i] = snakes[i].serialize();
    return new SerializablePopulation(serialSnakes, highscore, bestFitness, generation);
  }
  
  public void saveProgress() {
    try {
      OutputStream out = createOutput(peoplePath);
      ObjectOutputStream stream = new ObjectOutputStream(out);
      stream.writeObject(serialize());
      stream.close();
    } catch(IOException e) {
      println("Unable to save the model!");
      e.printStackTrace();
    }
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
  
  private int findBest() {
    return new Matrix(fitness).argmax().value;
  }
  
  private void updateStats(int best) {
    if (fitness[best] > bestFitness) {
      bestFitness = fitness[best];
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

Population loadFromFile(String path) {
  try {
    InputStream in = createInput(path);
    if (in == null) return null;
    ObjectInputStream stream = new ObjectInputStream(in);
    SerializablePopulation serialPeople = (SerializablePopulation) stream.readObject();
    stream.close();
    return new Population(serialPeople);
  } catch(IOException | ClassNotFoundException e) {
    println("Unable to load the model!");
    e.printStackTrace();
    return null;
  }
}
