class MatrixIndex {
  public int row, col, value;
  
  private MatrixIndex() {}
  
  public MatrixIndex(int row, int col, int cols) {
    this.row = row;
    this.col = col;
    value = row*cols+col;
  }
  
  public MatrixIndex(int value, int cols) {
    this.value = value;
    row = value/cols;
    col = value%cols;
  }
  
  public MatrixIndex plus(int drow, int dcol) {
    return new MatrixIndex(row+drow, col+dcol, (value-col)/row);
  }
  
  public MatrixIndex clone() {
    MatrixIndex clone = new MatrixIndex();
    clone.row = row;
    clone.col = col;
    clone.value = value;
    return clone;
  }
}
