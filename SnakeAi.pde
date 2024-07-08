int boardRows = 40, boardCols = 40;
float sceneSize = 720, spotSize;

float mutationRate = 0.05;

Population people;

float gameSpeed = 1;

void setup() {
  size(1280, 720);
  //frameRate(5);
  
  spotSize = (float) sceneSize/boardCols;
  people = new Population(2000);
}

void draw() {
  for (int i = 0; i < gameSpeed; i++)
    people.update();
    
  background(0);
  people.showBest(0, 0);
  people.showStats(sceneSize+20, 30);
  people.showBrain(sceneSize+118, 230, 0.9);
}

void keyPressed() {
  if (keyCode == RIGHT) gameSpeed++;
  else if (keyCode == LEFT && gameSpeed > 1) gameSpeed--;
}
