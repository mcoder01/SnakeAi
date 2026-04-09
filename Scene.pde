class Scene {
  private int rows, cols;
  private int[][] board;
  private MatrixIndex food;
  
  public Scene() {
    rows = boardRows;
    cols = boardCols;
    board = new int[rows][cols];
    init();
  }
  
  private void init() {
    for (int i = 0; i < cols; i++)
      board[0][i] = board[rows-1][i] = 1;
    
    for (int i = 0; i < rows; i++)
      board[i][0] = board[i][cols-1] = 1;
  }
  
  public void update() {
    if (food == null) spawnFood();
  }
  
  private void spawnFood() {
    int row, col;
    do {
      row = (int) random(rows);
      col = (int) random(cols);
    } while(board[row][col] != 0);
    food = new MatrixIndex(row, col, cols);
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
  
  public int reachableFreeCells(MatrixIndex source) {
    int reachableFreeCells = 0;
    boolean[][] visited = new boolean[rows][cols];
    LinkedList<MatrixIndex> queue = new LinkedList<>();
    queue.add(source);
    while(queue.size() > 0) {
      MatrixIndex cell = queue.poll();
      if (board[cell.row][cell.col] == 1 || board[cell.row][cell.col] == 2)
        continue;
        
      if (visited[cell.row][cell.col]) 
        continue;
      
      visited[cell.row][cell.col] = true;
      reachableFreeCells++;
      
      queue.add(cell.plus(-1, 0));
      queue.add(cell.plus(0, 1));
      queue.add(cell.plus(1, 0));
      queue.add(cell.plus(0, -1));
    }
    
    return reachableFreeCells;
  }
  
  public int totalSpace() {
    return (rows-2)*(cols-2);
  }
}
