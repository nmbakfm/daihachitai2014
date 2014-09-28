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
  
  // Arduino
  println(Serial.list());
  port = new Serial(this, Serial.list()[5], 9600);
  
  
  // load data
  minim = new Minim(this);
  for(int i=0; i<SOUND_NUM; ++i){
    player[i] = minim.loadFile("Fan/Fan"+i+".mp3");
  }
  
  explosions = new PImage[23];
  for(int i=0; i<explosions.length; ++i){
    explosions[i] = loadImage("explosions/explosion_"+nf(i,2)+".png");
  }
  
  mawarunyoros = new PImage[22];
  for(int i=0; i<mawarunyoros.length; ++i){
    mawarunyoros[i] = loadImage("mawarunyoros/mawarunyoro_"+nf(i,2)+".png");
  }
  
  linecircles = new PImage[22];
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
    println("hello");
    sprites.add(new Sprite());
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

//class Sprite{
//  int explosion_image_count = 0;
//
//  
//  Sprite(){
//    
//  }
//  
//  void draw(){
//    image(explosions[explosion_image_count], width/2, height/2);
//    ++explosion_image_count;
//  }
//  
//  boolean isDead(){
//    return (explosion_image_count >= explosions.length);
//  }
//}

//class Sprite{
//  int mawarunyoro_image_count = 0;
//
//  
//  Sprite(){
//    
//  }
//  
//  void draw(){
//    image(mawarunyoros[mawarunyoro_image_count], width/2, height/2);
//    ++mawarunyoro_image_count;
//  }
//  
//  boolean isDead(){
//    return (mawarunyoro_image_count >= mawarunyoros.length);
//  }
//}

class Sprite{
  int linecircle_image_count = 0;

  
  Sprite(){
    
  }
  
  void draw(){
    image(linecircles[mawarunyoro_image_count], width/2, height/2);
    ++linecircle_image_count;
  }
  
  boolean isDead(){
    return (linecircle_image_count >= linecircles.length);
  }
}

