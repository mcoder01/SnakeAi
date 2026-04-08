import java.util.function.Function;

ActivationFunc relu = x -> max(0, x);
ActivationFunc sigmoid = x -> 1.0/(1+exp(-x));

class Layer {
  private Matrix weights, output;
  private ActivationFunc activation;
  
  public Layer(Matrix weights, ActivationFunc activation) {
    this.weights = weights;
    this.activation = activation;
  }
  
  public Layer(int inputs, int nodes, ActivationFunc activation) {
    this(new Matrix(inputs+1, nodes), activation);
    weights.randomFill(-1, 1);
  }
  
  public Layer(SerializableLayer serialLayer) {
    this(new Matrix(serialLayer.weights), serialLayer.activation);
  }
  
  public Matrix forward(Matrix x) {
    output = weights.transpose().times(x);
    if (activation != null)
      output = output.map(activation);
    return output;
  }
  
  public void mutate(float rate) {
    weights.mutate(rate);
  }
  
  public Layer clone() {
    return new Layer(weights.clone(), activation);
  }
  
  public int inputs() {
    return weights.rows-1;
  }
  
  public int nodes() {
    return weights.cols;
  }
  
  public SerializableLayer serialize() {
    return new SerializableLayer(weights.serialize(), activation);
  }
}

Layer[] crossover(Layer father, Layer mother) {
  Matrix[] cw = crossover(father.weights, mother.weights);
  return new Layer[] {
    new Layer(cw[0], father.activation),
    new Layer(cw[1], father.activation)
  };
}
