class Scene {
  private int rows, cols;
  private int[][] board;
  private MatrixIndex food;
  private boolean replay;
  
  private ArrayList<MatrixIndex> foodHistory;
  private int historyIndex;
  
  public Scene() {
    rows = boardRows;
    cols = boardCols;
    
    board = new int[rows][cols];
    foodHistory = new ArrayList<>();
    init();
  }
  
  private void init() {
    for (int i = 0; i < cols; i++)
      board[0][i] = board[rows-1][i] = 1;
    
    for (int i = 0; i < rows; i++)
      board[i][0] = board[i][cols-1] = 1;
  }
  
  public void replay() {
    board[food.row][food.col] = 0;
    food = null;
    replay = true;
    historyIndex = 0;
  }
  
  public void update() {
    if (food == null) spawnFood();
  }
  
  private void spawnFood() {
    if (replay) food = foodHistory.get(historyIndex++);
    else {
      int row, col;
      do {
        row = (int) random(rows);
        col = (int) random(cols);
      } while(board[row][col] != 0);
      food = new MatrixIndex(row, col, cols);
      foodHistory.add(food);
    }
    board[food.row][food.col] = 3;
  }
  
  public void show(float x, float y) {
    pushMatrix();
    translate(x, y);
    noStroke();
    for (int i = 0; i < rows; i++)
      for (int j = 0; j < cols; j++) {
        if (board[i][j] == 0) continue;
        else if (board[i][j] == 1) fill(255);
        else if (board[i][j] == 2) fill(0, 255, 0);
        else if (board[i][j] == 3) fill(255, 0, 0);
        rect(j*spotSize, i*spotSize, spotSize, spotSize);
      }
    
    popMatrix();
  }
}
