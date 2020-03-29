import processing.sound.*;

AudioIn IN;
Amplitude nivel;
String woodFile = "frontend-large.jpg";
PShape cylinder;
PImage woodTexture;

boolean outOfBounds = false;
boolean leftPress = false, rightPress = false;
int redLinePos = 50;
int volumeBarHeight = 100;
int volumeBarMaxWidth = 600;
int depth = 30, radius = 20;
int wCenter = width / 2;
int hCenter = (int)(height * 0.7);
int planeWidth = 600;
int planeHeight = 15;
int planeDepth = depth;
int cylinderPosX = 0;
int cylinderPosY = 0;
int cylinderPosZ = 0;
int step = 1;
float g = 1.5;
float friction = 0.1;
int planeDirection = 1;
float planeAngle = 30;
int maxAngle = 30;
int minAngle = -30;
float angleStep = 0;
float maxAngleStep = 3;
float speed = 0;

void setup(){
  size(1200, 800, P3D);
  rectMode(CENTER);
  cylinder = createCylinder(depth, radius, 20);
  wCenter = width / 2;
  hCenter = (int)(height * 0.7);
  woodTexture = loadImage(woodFile);
  
  //conf
  rectMode(CENTER);
  
  //Sound configuration
  IN = new AudioIn(this, 0);
  IN.start();
  nivel = new Amplitude(this);
  nivel.input(IN);
}


void draw(){
 background(0);
 camera();
 
 drawText();
 angleStep = 0;
 float volume = nivel.analyze();
 
 int ancho = int(map(volume, 0, 1, 1, volumeBarMaxWidth));
 
 pushMatrix();
 translate(width / 2 - 300, height * 0.2);
 myRect(ancho);
 stroke(255, 0, 0);
 line(redLinePos, 0, redLinePos, volumeBarHeight);
 popMatrix();
 
 setAngleStep(ancho);
 
 pushMatrix();
 translate(width/ 2, height * 0.7);
 
 pushMatrix();
 rotateZ(radians(planeAngle));
 plane();
 popMatrix();
 pushMatrix();
 translate(cylinderPosX, -radius - 5 + cylinderPosY, cylinderPosZ);
 shape(cylinder);
 popMatrix();
 popMatrix();
 movePlane();
 if (outOfBounds){
   cylinderPosY += abs(speed);
   cylinderPosX += speed;
 }else{
   moveCylinder();
   calculateSpeed();
 }
}

void drawText(){
  textSize(25);
  textAlign(CENTER);
  text("Haz sonidos para balancear el cilindro", width / 2, height * 0.4, 0);
  text("La linea roja indica el punto de inflexión del angulo de rotación", width / 2, height * 0.15, 0);
}

void setAngleStep(int ancho){
  int newAngle = int(abs(redLinePos - ancho) % abs(maxAngleStep));
  angleStep = newAngle * (ancho > redLinePos ? 1 : -1) ; 
}


void moveCylinder(){
  cylinderPosX += speed;
  int a = (int)(cos(radians(planeAngle)) * planeWidth / 2);
  if (cylinderPosX > a || cylinderPosX < -a){
    outOfBounds = true;
  }else{
    cylinderPosY = (int)(tan(radians(planeAngle)) * cylinderPosX);
  }
}

void movePlane(){
  if (angleStep < 0){
    planeAngle += (planeAngle <= minAngle) ? 0 : angleStep;
  }else{
    planeAngle += (planeAngle >= maxAngle) ? 0 : angleStep;
  }
}


void keyReleased(){
  if (keyCode == LEFT){
    leftPress = false; 
  }else if (keyCode == RIGHT){
    rightPress = false;
  }
}


void keyPressed(){
  if (keyCode == LEFT){
    leftPress = true; 
  }else if (keyCode == RIGHT){
    rightPress = true;    
  }
}

void calculateSpeed(){
  float acc = sin(radians(planeAngle)) * g;
  speed += (acc * friction); 
}

void plane(){
  if (woodTexture == null){
    woodTexture = loadImage(woodFile);
  }
  beginShape();
  box(planeWidth, planeHeight, planeDepth);
  texture(woodTexture);
  endShape();
}


void myRect(int w){
  beginShape();
  vertex(0, 0, 0);
  vertex(0 + w, 0, 0);
  vertex(0 + w, volumeBarHeight, 0);
  vertex(0, volumeBarHeight, 0);
  endShape(CLOSE);
}

// https://forum.processing.org/two/discussion/26800/how-to-create-a-3d-cylinder-using-pshape-and-vertex-x-y-z
PShape createCylinder(int sides, float r, float h) {
 
  PShape cylinder = createShape(GROUP);
 
  float angle = 360 / sides;
  float halfHeight = h / 2;
 
  // draw top of the tube
  PShape top = createShape();
  top.beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    top.vertex( x, y, -halfHeight);
  }
  top.endShape(CLOSE);
  cylinder.addChild(top);
 
  // draw bottom of the tube
  PShape bottom = createShape();
  bottom.beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    bottom.vertex( x, y, halfHeight);
  }
  bottom.endShape(CLOSE);
  cylinder.addChild(bottom);
 
  // draw sides
  PShape middle = createShape();
  middle.beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides + 1; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    middle.vertex( x, y, halfHeight);
    middle.vertex( x, y, -halfHeight);
  }
  middle.endShape(CLOSE);
  cylinder.addChild(middle);
  
  return cylinder;
}
