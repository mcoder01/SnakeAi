class Model {
  private int[] layers;
  private Matrix[] weights;
  private Matrix input, output;
  
  public Model(int... layers) {
    this.layers = layers;
    weights = new Matrix[layers.length-1];
    for (int i = 0; i < weights.length; i++)
      weights[i] = new Matrix(layers[i]+1, layers[i+1]);
  }
  
  public void randomInit() {
    for (int i = 0; i < weights.length; i++)
      weights[i].randomFill(-1, 1);
  }
  
  public Matrix forward(Matrix x) {
    input = x;
    Matrix y = x.transpose();
    for (int i = 0; i < weights.length; i++)
      y = y.addColumn(1).times(weights[i]).map(this::relu);
    
    output = y.transpose();
    return output;
  }
  
  private float relu(float value) {
    return max(0, value);
  }
  
  public Model crossover(Model partner) {
    Model model = new Model(layers);
    for (int i = 0; i < weights.length; i++)
      model.weights[i] = weights[i].crossover(partner.weights[i]);
    return model;
  }
  
  public void mutate(float rate) {
    for (Matrix m : weights)
      m.mutate(rate);
  }
  
  public void show(float x, float y) {
  }
}
