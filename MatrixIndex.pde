class MatrixIndex {
  public int row, col, index;
  
  private MatrixIndex() {}
  
  public MatrixIndex(int row, int col, int cols) {
    this.row = row;
    this.col = col;
    index = row*cols+col;
  }
  
  public MatrixIndex(int index, int cols) {
    this.index = index;
    row = index/cols;
    col = index%cols;
  }
  
  public MatrixIndex clone() {
    MatrixIndex clone = new MatrixIndex();
    clone.row = row;
    clone.col = col;
    clone.index = index;
    return clone;
  }
}
