class Snake extends ArrayList<MatrixIndex> {
  private Scene scene;
  private int orientation, score;
  
  private Model brain;
  private int steps, lifeTime;
  
  public Snake() {
    super(3);
    scene = new Scene();
    brain = new Model(24, 32, 32, 4);
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
        steps += 100;
        if (steps > 500)
          steps = 500;
      }
      
      steps--;
      lifeTime++;
      scene.board[index.row][index.col] = 2;
    }
  }
  
  private void lookAndThink() {
    float[] inputs = new float[24];
    for (int i = 0; i < 8; i++) {
      PVector dir = PVector.fromAngle(i/8.0*TWO_PI);
      int drow = (int) (-dir.y/abs(dir.y));
      int dcol = (int) (dir.x/abs(dir.x));
      lookAt(inputs, i*3, drow, dcol);
    }
    
    Matrix x = new Matrix(inputs);
    Matrix y = brain.forward(x);
    orientate(y.argmax());
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
    do {
      index.row += rowDir;
      index.col += colDir;
      distance++;
      if (vision[i+1] == 0 && scene.board[index.row][index.col] == 2)
        vision[i+1] = 1;
      else if (vision[i+2] == 0 && scene.board[index.row][index.col] == 3)
        vision[i+2] = 1;
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
    float fitness = pow(lifeTime, 2);
    if (score < 10)
      fitness *= pow(2, score);
    else fitness *= pow(2, 10)*(score-9);
    return fitness;
  }
  
  public boolean isAlive() {
    return steps > 0;
  }
}
