class Snake extends ArrayList<MatrixIndex> {
  private Scene scene;
  private int orientation, score;
  
  private Model brain;
  private int steps, lifeTime;
  
  public Snake() {
    super(3);
    scene = new Scene();
    brain = new Model(15, 16, 16, 3);
    brain.randomInit();
    reset(false);
  }
  
  public void reset(boolean replay) {
    for (MatrixIndex index : this)
      if (scene.board[index.row][index.col] == 2)
        scene.board[index.row][index.col] = 0;
    
    clear();
    if (replay) scene.replay();
    for (int i = 2; i >= 0; i--) {
      MatrixIndex index = new MatrixIndex(scene.rows/2, scene.cols/2+i-1, scene.cols);
      scene.board[index.row][index.col] = 2;
      add(index);
    }
    
    orientation = 0;
    score = 0;
    steps = 200;
    lifeTime = 0;
  }
  
  public void update() {
    if (!isAlive()) return;
    
    MatrixIndex tail = get(size()-1);
    scene.board[tail.row][tail.col] = 0;
    
    for (int i = size()-1; i > 0; i--)
      set(i, get(i-1).clone());
    
    lookAndThink();
    MatrixIndex index = get(0);
    if (orientation == 0) index.col++;
    else if (orientation == 1) index.row--;
    else if (orientation == 2) index.col--;
    else index.row++;
    
    if (scene.board[index.row][index.col] == 1 || scene.board[index.row][index.col] == 2)
      steps = 0;
    else {
      if (scene.board[index.row][index.col] == 3) {
        add(get(size()-1).clone());
        score++;
        scene.food = null;
        if (steps < 100) steps += 50;
        if (steps < 500 || score > 40)
          steps += 100;
      }
      
      steps--;
      lifeTime++;
      scene.board[index.row][index.col] = 2;
    }
  }
  
  private void lookAndThink() {
    float[] inputs = new float[15];
    for (int i = 0; i < 5; i++) {
      PVector dir = PVector.fromAngle(i/4.0*PI-HALF_PI+orientation*HALF_PI);
      int drow = (int) (-dir.y/abs(dir.y));
      int dcol = (int) (dir.x/abs(dir.x));
      lookAt(inputs, i*3, drow, dcol);
    }
    
    Matrix x = new Matrix(inputs);
    Matrix y = brain.forward(x);
    turn(y.argmax()-1);
  }
  
  public void turn(int dir) {
    orientation += dir;
    if (orientation == 4) orientation = 0;
    else if (orientation == -1) orientation = 3;
  }
  
  public void orientate(int dir) {
    if (dir == orientation || dir == (orientation+2)%4
        || dir < 0 || dir > 3) 
        return;
    orientation = dir;
  }
  
  private void lookAt(float[] vision, int i, int rowDir, int colDir) {
    MatrixIndex index = get(0).clone();
    float distance = 0;
    boolean foundTail = false, foundFood = false;
    do {
      index.row += rowDir;
      index.col += colDir;
      distance++;
      if (!foundTail && scene.board[index.row][index.col] == 2) {
        vision[i+1] = 1.0/distance;
        foundTail = true;
      } else if (!foundFood && scene.board[index.row][index.col] == 3) {
        vision[i+2] = 1;
        foundFood = true;
      }
    } while(scene.board[index.row][index.col] != 1);
    vision[i] = 1.0/distance;
  }
  
  public Snake crossover(Snake partner) {
    Snake snake = new Snake();
    snake.brain = brain.crossover(partner.brain);
    return snake;
  }
  
  public void mutate(float rate) {
    brain.mutate(rate);
  }
  
  public float fitness() {
    if (score < 10)
      return pow(lifeTime, 2)*pow(2, score);
    return pow(lifeTime, 2)*pow(2, 10)*(score-9);
  }
  
  public boolean isAlive() {
    return steps > 0;
  }
}
