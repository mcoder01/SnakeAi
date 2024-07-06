import java.util.function.Function;
import java.util.function.Consumer;

class Matrix {
  private float[][] data;
  private int rows, cols;
  
  public Matrix(int rows, int cols) {
    this.rows = rows;
    this.cols = cols;
    data = new float[rows][cols];
  }
  
  public Matrix(float... data) {
    this(data.length, 1);
    for (int i = 0; i < rows; i++)
      this.data[i][0] = data[i];
  }
  
  private void forEach(Consumer<MatrixIndex> action) {
    for (int i = 0; i < rows; i++)
      for (int j = 0; j < cols; j++)
        action.accept(new MatrixIndex(i, j, cols));
  }
  
  private void internalMap(Function<MatrixIndex, Float> action) {
    forEach(index -> data[index.row][index.col] = action.apply(index));
  }
  
  public Matrix map(Function<Float, Float> action) {
    Matrix result = new Matrix(rows, cols);
    result.internalMap(index -> action.apply(data[index.row][index.col]));
    return result;
  }
  
  public void fill(float value) {
    internalMap(index -> value);
  }
  
  public void randomFill(float min, float max) {
    internalMap(index -> random(min, max));
  }
  
  public Matrix add(Matrix m) {
    if (rows != m.rows || cols != m.cols)
      return null;
      
    Matrix result = new Matrix(rows, cols);
    result.internalMap(index -> data[index.row][index.col]+m.data[index.row][index.col]);
    return result;
  }
  
  public Matrix times(Matrix m) {
    if (cols != m.rows) return null;
    
    Matrix result = new Matrix(rows, m.cols);
    result.internalMap(index -> {
      float sum = 0;
      for (int i = 0; i < cols; i++)
        sum += data[index.row][i]*m.data[i][index.col];
      return sum;
    });
    
    return result;
  }
  
  public Matrix transpose() {
    Matrix result = new Matrix(cols, rows);
    result.internalMap(index -> data[index.col][index.row]);
    return result;
  }
  
  public int argmax() {
    MatrixIndex maxIndex = new MatrixIndex(0, 0, cols);
    forEach(index -> {
      if (data[index.row][index.col] > data[maxIndex.row][maxIndex.col]) {
        maxIndex.row = index.row;
        maxIndex.col = index.col;
      }
    });
        
    return maxIndex.row*cols+maxIndex.col;
  }
  
  public Matrix crossover(Matrix partner) {
    int randRow = floor(random(rows));
    int randCol = floor(random(cols));
    
    Matrix matrix = new Matrix(rows, cols);
    matrix.internalMap(index -> {
      if (index.row < randRow || (index.row == randRow && index.col <= randCol))
        return data[index.row][index.col];
      return partner.data[index.row][index.col];
    });
    
    return matrix;
  }
  
  public void mutate(float rate) {
    internalMap(index -> {
      float value = data[index.row][index.col];
      if (random(1) < rate)
        value = constrain(value+randomGaussian()/5, -1, 1);
      return value;
    });
  }
  
  public Matrix addColumn(float... values) {
    if (values.length != rows) return null;
    
    Matrix result = new Matrix(rows, cols+1);
    result.internalMap(index -> {
      if (index.col < cols)
        return data[index.row][index.col];
      return values[index.row];
    });
    
    return result;
  }
  
  public float get(int row, int col) {
    return data[row][col];
  }
  
  public float[] toArray() {
    float[] array = new float[rows*cols];
    forEach(index -> array[index.row*cols+index.col] = data[index.row][index.col]);
    return array;
  }
}
