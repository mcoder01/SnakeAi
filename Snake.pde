class Snake extends ArrayList<MatrixIndex> {
  public Scene scene;
  protected int id, orientation, score;
  private boolean alive;
  protected String deathCause;
  
  public Snake(int id) {
    super(3);
    this.id = id;
    scene = new Scene();
    reset(false);
  }
  
  public Snake() {
    this(0);
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
    alive = true;
  }
  
  public void update() {
    if (!isAlive()) return;
    
    MatrixIndex tail = get(size()-1);
    scene.board[tail.row][tail.col] = 0;
    
    for (int i = size()-1; i > 0; i--)
      set(i, get(i-1).clone());
    
    MatrixIndex head = get(0);
    if (orientation == 0) head.col++;
    else if (orientation == 1) head.row--;
    else if (orientation == 2) head.col--;
    else head.row++;
    
    if (scene.board[head.row][head.col] == 1)
      kill("wall");
    else if (scene.board[head.row][head.col] == 2)
      kill("bite");
    else if (scene.board[head.row][head.col] == 3)
      eat();
    
    scene.board[head.row][head.col] = 2;
  }
  
  public void kill(String cause) {
    deathCause = cause;
    alive = false;
  }
  
  public void eat() {
    add(get(size()-1).clone());
    score++;
    scene.food = null;
  }
  
  public void turn(int dir) {
    orientation += dir;
    if (orientation == 4) orientation = 0;
    else if (orientation == -1) orientation = 3;
  }
  
  public void orientate(int dir) {
    if (isOrientationValid(dir))
      orientation = dir;
  }
  
  public boolean isOrientationValid(int dir) {
    return dir != (orientation+2)%4 && dir >= 0 && dir <= 3;
  }
  
  public boolean isAlive() {
    return alive;
  }
  
  public float showStats(float x, float y) {
    textAlign(LEFT, CENTER);
    fill(255);
    noStroke();
    
    float currY = y;
    textSize(24);
    if (id > 0) {
      text("SNAKE #" + id, x, currY);
      currY += 35;
      textSize(18);
    }
    
    text("SCORE: " + score, x, currY);
    return currY+25;
  }
  
  public void setId(int id) {
    this.id = id;
  }
}
