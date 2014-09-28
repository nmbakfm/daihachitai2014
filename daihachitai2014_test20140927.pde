import ddf.minim.*;

import processing.serial.*;
import processing.video.*;

final int NUM = 5;
final int SOUND_NUM = 5;

Minim minim;
AudioPlayer[] player = new AudioPlayer[SOUND_NUM];

Serial port;
int[] untouched_count = new int[NUM];
boolean[] touched = new boolean[NUM];

PImage[] explosions = new PImage[23];
int explosion_image_count = 0;
boolean explosion_image_playing = false;

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
  for(int i=0; i<explosions.length; ++i){
    explosions[i] = loadImage("explosions/explosion_"+nf(i,2)+".png");
  }
  
  minim = new Minim(this);
  for(int i=0; i<SOUND_NUM; ++i){
    player[i] = minim.loadFile("Fan/Fan"+i+".mp3");
  }
  
  // initialize
  for(int i=0; i<NUM; ++i){
    untouched_count[i] = 0;
    touched[i] = false;
  }
}

void draw(){
  background(255);
  for(int i=0; i<NUM; ++i){
    if(i==0) drawStick(i, touched[i]);
  }
}

void drawStick(int stick_id, boolean stickTouched){
  if(stickTouched){
    if(!explosion_image_playing){
      int sound_id = (int)random(0,SOUND_NUM);
      player[sound_id].rewind();
      player[sound_id].play();
    }
    explosion_image_playing = true;
  }
  if(explosion_image_playing){
    image(explosions[explosion_image_count], width/2, height/2);
    ++explosion_image_count;
    if(explosion_image_count>=explosions.length){
      explosion_image_count = 0;
      explosion_image_playing = false;
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

