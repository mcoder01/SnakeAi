import java.util.function.Function;
import java.io.*;

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

class SerializablePopulation implements Serializable {
  public SerializableModel[] brains;
  public int generation;
  
  public SerializablePopulation(SerializableModel[] brains, int generation) {
    this.brains = brains;
    this.generation = generation;
  }
};

class Champion implements Serializable {
  public SerializableModel brain;
  public int score;
  public float fitness;
  
  public Champion(SerializableModel brain, int score, float fitness) {
    this.brain = brain;
    this.score = score;
    this.fitness = fitness;
  }
};

class Serializer {
  public static void save(String path, Serializable obj) {
    try {
      FileOutputStream out = new FileOutputStream(path);
      ObjectOutputStream stream = new ObjectOutputStream(out);
      stream.writeObject(obj);
      stream.close();
    } catch(IOException e) {
      e.printStackTrace();
    }
  }

  public static Object load(String path) {
    try {
      FileInputStream in = new FileInputStream(path);
      ObjectInputStream stream = new ObjectInputStream(in);
      Object obj = stream.readObject();
      stream.close();
      return obj;
    } catch(IOException | ClassNotFoundException e) {
      System.out.println("Unable to load the object!");
      return null;
    }
  }
};
