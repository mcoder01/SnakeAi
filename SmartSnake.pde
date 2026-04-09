import java.util.LinkedList;

class SmartSnake extends Snake {
  private Model brain;
  private int steps, lifeTime;
  private final int startingSteps, foodReward;
  
  public SmartSnake(int id, Model brain) {
    super(id);
    this.brain = brain;
    startingSteps = (int) (maxSteps*0.2);
    foodReward = 50;
  }
  
  public SmartSnake(int id) {
    this(id, new Model(9, 16, 16, 3));
  }
  
  public void reset() {
    super.reset();
    steps = startingSteps;
    lifeTime = 0;
  }
  
  public void update() {
    if (!isAlive()) 
      return;
      
    lookAndThink();
    super.update();
    if (!isAlive()) 
      return;
    
    lifeTime++;
    steps--;
    if (steps == 0)
      kill("steps");
  }
  
  private void lookAndThink() {
    float[] inputs = new float[9];
    lookAt(inputs, 0, (orientation+1)%4); // Look at left
    lookAt(inputs, 3, orientation); // Look at front
    lookAt(inputs, 6, orientation > 0 ? orientation-1 : 3); // Look at right
    
    Matrix x = new Matrix(inputs);
    Matrix y = brain.forward(x);
    turn(y.argmax().value-1);
  }
  
  private void lookAt(float[] vision, int i, int dir) {
    int drow = dir == 1 ? -1 : dir == 3 ? 1 : 0;
    int dcol = dir == 0 ? 1 : dir == 2 ? -1 : 0;
    
    MatrixIndex index = get(0);
    int rowsToFood = scene.food.row-index.row;
    int colsToFood = scene.food.col-index.col;
    if (rowsToFood*drow > 0)
      vision[i+2] = 1.0/abs(rowsToFood);
    else if (colsToFood*dcol > 0)
      vision[i+2] = 1.0/abs(colsToFood);
    
    float distance = 0;
    boolean foundTail = false;
    do {
      index = index.plus(drow, dcol);
      distance++;
      if (!foundTail && scene.board[index.row][index.col] == 2) {
        vision[i+1] = 1.0/distance;
        foundTail = true;
      }
    } while(scene.board[index.row][index.col] != 1);
    vision[i] = 1.0/distance;
  }
 
  public void eat() {
    super.eat();
    steps = min(steps+foodReward, maxSteps);
  }
  
  public void mutate(float rate) {
    brain.mutate(rate);
  }
  
  public float fitness() {
    float scoreReward = pow(score, 2)*200;
    float survivalReward = lifeTime*1.5;
    MatrixIndex source = get(deathCause.equals("steps") ? 0 : 1);
    float freeSpaceReward = scene.reachableFreeCells(source)*10;
    float bitePenalty = deathCause.equals("bite") ? -score*10 : 0;
    int usedSteps = startingSteps+foodReward*score-steps;
    float stepsPenalty = min(-usedSteps+foodReward*score, 0);
    return max(0, scoreReward+survivalReward+freeSpaceReward+bitePenalty+stepsPenalty);
  }
  
  public float showStats(float x, float y) {
    float currY = super.showStats(x, y);
    textSize(18);
    if (steps == 0) fill(255, 0, 0);
    else if (steps < 100) fill(255, 150, 0);
    else fill(255);
    text("LEFT MOVES: " + steps, x, currY);
    return currY+25;
  }
};

SmartSnake[] crossover(SmartSnake father, SmartSnake mother, int id1, int id2) {
  Model[] brains = crossover(father.brain, mother.brain);
  return new SmartSnake[] {
    new SmartSnake(id1, brains[0]), 
    new SmartSnake(id2, brains[1])
  };
}
