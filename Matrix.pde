import java.util.function.Function;
import java.util.function.Consumer;

class Matrix {
  private float[][] data;
  public int rows, cols;
  
  public Matrix(float[][] data, int rows, int cols) {
    this.data = data;
    this.rows = rows;
    this.cols = cols;
  }
  
  public Matrix(int rows, int cols) {
    this(new float[rows][cols], rows, cols);
  }
  
  public Matrix(float... data) {
    this(data.length, 1);
    for (int i = 0; i < rows; i++)
      this.data[i][0] = data[i];
  }
  
  public Matrix(SerializableMatrix serialMatrix) {
    this(serialMatrix.data, serialMatrix.rows, serialMatrix.cols);
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
  
  public Matrix scale(float factor) {
    return map(value -> value*factor);
  }
  
  public Matrix sub(Matrix m) {
    return add(m.scale(-1));
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
  
  public MatrixIndex argmax() {
    MatrixIndex maxIndex = new MatrixIndex(0, 0, cols);
    forEach(index -> {
      if (get(index) > get(maxIndex)) {
        maxIndex.row = index.row;
        maxIndex.col = index.col;
        maxIndex.value = index.value;
      }
    });
    
    return maxIndex;
  }
  
  public void mutate(float rate) {
    internalMap(index -> {
      if (random(1) < rate)
        return random(-1, 1);
      return data[index.row][index.col];
    });
  }
  
  public Matrix addRow(float... values) {
    if (values.length != cols) return null;
    
    Matrix result = new Matrix(rows+1, cols);
    result.internalMap(index -> {
      if (index.row < rows)
        return data[index.row][index.col];
      return values[index.col];
    });
    
    return result;
  }
  
  public float get(int row, int col) {
    return data[row][col];
  }
  
  public float get(MatrixIndex index) {
    return get(index.row, index.col);
  }
  
  public void set(int row, int col, float value) {
    data[row][col] = value;
  }
  
  public void set(MatrixIndex index, float value) {
    set(index.row, index.col, value);
  }
  
  public float[] toArray() {
    float[] array = new float[rows*cols];
    forEach(index -> array[index.row*cols+index.col] = data[index.row][index.col]);
    return array;
  }
  
  public Matrix clone() {
    return map(value -> value);
  }
  
  public SerializableMatrix serialize() {
    return new SerializableMatrix(data, rows, cols);
  }
}

Matrix[] crossover(Matrix father, Matrix mother) {
  Matrix child1 = new Matrix(father.rows, father.cols);
  Matrix child2 = new Matrix(father.rows, father.cols);
  int randIndex = floor(random(father.rows*father.cols));
  father.forEach(idx -> {
    child1.set(idx, idx.value < randIndex ? father.get(idx) : mother.get(idx));
    child2.set(idx, idx.value < randIndex ? mother.get(idx) : father.get(idx));
  });
  
  return new Matrix[] {child1, child2};
}
