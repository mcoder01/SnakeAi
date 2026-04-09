class Model {
  private Layer[] layers;
  private Matrix input;
  
  public Model(Layer[] layers) {
    this.layers = layers;
  }
  
  public Model(int... nodes) {
    this(new Layer[nodes.length-1]);
    for (int i = 0; i < layers.length; i++)
      layers[i] = new Layer(nodes[i], nodes[i+1], i < layers.length-1 ? relu : null);
  }
  
  public Model(SerializableModel serialModel) {
    layers = new Layer[serialModel.layers.length];
    for (int i = 0; i < layers.length; i++)
      layers[i] = new Layer(serialModel.layers[i]);
  }
  
  public Matrix forward(Matrix x) {
    input = x;
    Matrix y = x;
    for (int i = 0; i < layers.length; i++)
      y = layers[i].forward(y.addRow(1));
    return y.transpose();
  }
  
  public void mutate(float rate) {
    for (Layer l : layers)
      l.mutate(rate);
  }
  
  private float computeNodesGap(float h) {
    int maxNodes = layers[0].inputs();
    for (int i=0; i < layers.length; i++)
      if (layers[i].nodes() > maxNodes)
        maxNodes = layers[i].nodes();
    return h/maxNodes;
  }
  
  public void show(float x, float y, float scale) {
    float w = 500*scale;
    float h = 600*scale;
    float centerY = y+h/2;
    float nodeRadius = 15*scale;
    float nodesGap = computeNodesGap(h);
    float layersGap = w/(layers.length+1);
    float textSize = 14*(scale+0.1);
    
    // Draw connections
    for (int i = 0; i < layers.length; i++) {
      float nodeX = x+i*layersGap;
      for (int j = 0; j < layers[i].inputs(); j++) {
        float nodeY = centerY-nodesGap*(layers[i].inputs()/2.0-j);
        for (int k = 0; k < layers[i].nodes(); k += 3) {
          int index = min(k+j%3, layers[i].nodes()-1);
          float value = layers[i].weights.get(j, index);
          if (value >= 0) stroke(0, 0, 255);
          else stroke(255, 0, 0);
          line(nodeX, nodeY, nodeX+layersGap, centerY-nodesGap*(layers[i].nodes()/2.0-index));
        }
      }
    }
    
    // Draw nodes
    noStroke();
    for (int i = 0; i < layers.length+1; i++) {
      int nodes = i == 0 ? layers[0].inputs() : layers[i-1].nodes();
      Matrix output = i == 0 ? input : layers[i-1].output;
      float nodeX = x+i*layersGap;
      for (int j = 0; j < nodes; j++) {
        float nodeY = centerY-nodesGap*(nodes/2.0-j);
        if (output.get(j, 0) >= 0.5)
          fill(0, 255, 0);
        else fill(255);
        circle(nodeX, nodeY, nodeRadius);
      }
    }
    
    // Draw input names
    textSize(textSize);
    String[] inLabels = {
        "LEFT-WD", "LEFT-TD", "LEFT-FD",
        "FRONT-WD", "FRONT-TD", "FRONT-FD", 
        "RIGHT-WD", "RIGHT-TD", "RIGHT-FD"
    };
    
    for (int i = 0; i < layers[0].inputs(); i++) {
      float nodeY = centerY-nodesGap*(layers[0].inputs()/2.0-i);
      textAlign(RIGHT, CENTER);
      fill(255);
      text(inLabels[i], x-20, nodeY);
    }
    
    // Draw output names
    String[] outLabels = {"RIGHT", "FORWARD", "LEFT"};
    int nodes = layers[layers.length-1].nodes();
    for (int i = 0; i < nodes; i++) {
      float nodeY = centerY-nodesGap*(nodes/2.0-i);
      textAlign(LEFT, CENTER);
      fill(255);
      text(outLabels[i], x+layers.length*layersGap+20, nodeY);
    }
  }
  
  public SerializableModel serialize() {
    SerializableLayer[] serialLayers = new SerializableLayer[layers.length];
    for (int i = 0; i < layers.length; i++)
      serialLayers[i] = layers[i].serialize();
    return new SerializableModel(serialLayers);
  }
  
  public Matrix getInput() {
    return input;
  }
}

Model[] crossover(Model father, Model mother) {
  int layers = father.layers.length;
  Layer[] child1Layers = new Layer[layers];
  Layer[] child2Layers = new Layer[layers];
  
  int index = (int) random(layers);
  for (int i = 0; i < layers; i++) {
    if (i == index) {
      Layer[] cl = crossover(father.layers[i], mother.layers[i]);
      child1Layers[i] = cl[0];
      child2Layers[i] = cl[1];
    } else {
      Layer fatherLayer = father.layers[i].clone();
      Layer motherLayer = mother.layers[i].clone();
      child1Layers[i] = i < index ? fatherLayer : motherLayer;
      child2Layers[i] = i < index ? motherLayer : fatherLayer;
    }
  }
  
  return new Model[] { 
    new Model(child1Layers), 
    new Model(child2Layers)
  };
}
