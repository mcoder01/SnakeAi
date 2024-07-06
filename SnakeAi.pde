int boardRows = 40, boardCols = 40;
float spotSize;

Population people;

void setup() {
  size(900, 600);
  //frameRate(5);
  
  spotSize = (float) 600/boardCols;
  people = new Population(2000);
}

void draw() {
  people.update();
  background(0);
  people.showBest();
}

/*void keyPressed() {
  if (keyCode == RIGHT) snake.orientate(0);
  else if (keyCode == DOWN) snake.orientate(1);
  else if (keyCode == LEFT) snake.orientate(2);
  else if (keyCode == UP) snake.orientate(3);
}*/
