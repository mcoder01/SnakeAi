import java.util.function.Function;
import java.io.Serializable;

interface ActivationFunc extends Function<Float, Float>, Serializable {};

class SerializableMatrix implements Serializable {
  public float[][] data;
  public int rows, cols;
  
  public SerializableMatrix(float[][] data, int rows, int cols) {
    this.data = data;
    this.rows = rows;
    this.cols = cols;
  }
};

class SerializableLayer implements Serializable {
  public SerializableMatrix weights;
  public ActivationFunc activation;
  
  public SerializableLayer(SerializableMatrix weights, ActivationFunc activation) {
    this.weights = weights;
    this.activation = activation;
  }
};

class SerializableModel implements Serializable {
  public SerializableLayer[] layers;
  
  public SerializableModel(SerializableLayer[] layers) {
    this.layers = layers;
  }
};

class SerializableSnake implements Serializable {
  public int id;
  public SerializableModel brain;
  
  public SerializableSnake(int id, SerializableModel brain) {
    this.id = id;
    this.brain = brain;
  }
};

class SerializablePopulation implements Serializable {
  public SerializableSnake[] snakes;
  public int highscore, generation;
  public float bestFitness;
  
  public SerializablePopulation(SerializableSnake[] snakes, int highscore, float bestFitness, int generation) {
    this.snakes = snakes;
    this.highscore = highscore;
    this.bestFitness = bestFitness;
    this.generation = generation;
  }
};
