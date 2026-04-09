int boardRows = 30, boardCols = 30, sceneSize = 720;
float spotSize;

float gameSpeed = 1;
boolean pause = false;

Population people;
float mutationRate = 0.03;
int maxSteps = 800;
String peoplePath, championPath;

void setup() {
  size(1280, 720);
  peoplePath = dataPath("population.dat");
  championPath = dataPath("champion.dat");
  
  spotSize = (float) sceneSize/boardCols;
  SerializablePopulation serialPeople = 
    (SerializablePopulation) Serializer.load(peoplePath);
  if (serialPeople != null)
    people = new Population(serialPeople);
  else people = new Population(2000);
  people.reset();
}

void draw() {
  background(0);
  if (!pause)
    for (int i = 0; i < gameSpeed; i++)
      people.update();
      
  SmartSnake snake = people.getShowing();
  if (snake == null) return;
  snake.scene.show(0, 0);
  snake.showStats(50, 60);
    
  people.showStats(sceneSize+20, 30);
  snake.brain.show(sceneSize+140, 200, 0.75);
}

void keyPressed() {
  if (keyCode == RIGHT) gameSpeed++;
  else if (keyCode == LEFT && gameSpeed > 1) gameSpeed--;
  else if (key == ' ') pause = !pause;
}
