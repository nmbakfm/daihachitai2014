import ddf.minim.*;

import processing.serial.*;
import processing.video.*;

final int NUM = 5;
final int SOUND_NUM = 5;

static PImage[] explosions;
static PImage[] mawarunyoros;
static PImage[] linecircles;

ArrayList<Sprite> sprites = new ArrayList<Sprite>();

Minim minim;
AudioPlayer[] player = new AudioPlayer[SOUND_NUM];

Serial port;
int[] untouched_count = new int[NUM];
boolean[] touched = new boolean[NUM];
boolean[] pTouched = new boolean[NUM];

void setup(){
  
  // fundamental settings
  frameRate(30);
  size(displayWidth, displayHeight);
  
  imageMode(CENTER);
  noCursor();
  colorMode(HSB);
  
  // Arduino
  println(Serial.list());
  port = new Serial(this, Serial.list()[2], 9600);
  
  
  // load data
  minim = new Minim(this);
  for(int i=0; i<SOUND_NUM; ++i){
    player[i] = minim.loadFile("Fan/Fan"+i+".mp3");
  }
  
  explosions = new PImage[24];
  for(int i=0; i<explosions.length; ++i){
    explosions[i] = loadImage("explosions/explosion_"+nf(i,2)+".png");
  }
  
  mawarunyoros = new PImage[24];
  for(int i=0; i<mawarunyoros.length; ++i){
    mawarunyoros[i] = loadImage("mawarunyoros/mawarunyoro_"+nf(i,2)+".png");
  }
  
  linecircles = new PImage[95];
  for(int i=0; i<linecircles.length; ++i){
    linecircles[i] = loadImage("linecircles/linecircle_"+nf(i,2)+".png");
  }
  // initialize
  for(int i=0; i<NUM; ++i){
    untouched_count[i] = 0;
    touched[i] = false;
  }
  
}

void draw(){
  background(0);
  for(int i=0; i<NUM; ++i){
    if(i==0) drawStick(i, touched[i]);
  }
}

void drawStick(int stick_id, boolean stickTouched){
//    println("untouched:" + !touched[stick_id]);
//    println("stickTouched:" + stickTouched);
  if(stickTouched && !pTouched[stick_id]){
    int image_id = (int)random(0,3);
    if(image_id==0){ sprites.add(new Sprite(explosions, color(random(0,255),255,255))); }
    else if(image_id==1){sprites.add(new Sprite(mawarunyoros, color(random(0,255),255,255)));}
    else if(image_id==2){sprites.add(new Sprite(linecircles, color(random(0,255),255,255)));}
    int sound_id = (int)random(0,SOUND_NUM);
    player[sound_id].rewind();
    player[sound_id].play();
  }
  
  pTouched[stick_id] = stickTouched;
  
  for(Sprite s : sprites){
    s.draw();
  }
  for(int i=0; i<sprites.size(); ++i){
    if(sprites.get(i).isDead()){
      sprites.remove(i);
      --i;
    }
  }
}


void serialEvent(Serial p){
  int received_data = Integer.parseInt(port.readString());
  int received_id = received_data%5;
  
  if(received_data >= 5){
    ++untouched_count[received_id];
    if(untouched_count[received_id] > 2){
      touched[received_id] = false;
    }
  }else{
    touched[received_id] = true;
    untouched_count[received_id] = 0;
  }
  
}

void movieEvent(Movie m){
  m.read();
}

void stop()
{
  for(int i=0; i<SOUND_NUM; ++i){
    player[i].close();
  }
  minim.stop();
  super.stop();
} 

class Sprite{
  int image_count = 0;
  PImage[] images;
  color col;
  
  Sprite(PImage[] _images, color _col){
    images = _images;
    col = _col;
  }
  
  void draw(){
    tint(col);
    image(images[image_count], width/2, height/2);
    ++image_count;
  }
  
  boolean isDead(){
    return (image_count >= images.length);
  }
}

