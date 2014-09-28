int const NUM = 2;
int current[NUM];

void setup(){
  Serial.begin(9600);
  for(int i=0; i<NUM; i++){
    current[i] = LOW;
    pinMode(i*2+4, INPUT);
    pinMode(i*2+5, OUTPUT);
    digitalWrite(i*2+5, current[i]);
  }
}

void loop(){
  for(int i=0; i<NUM; i++){
    current[i] = (current[i]==HIGH) ? LOW : HIGH;
    
    digitalWrite(i*2+5, current[i]);
    int j = 0;
    
    bool result = false;
    while (digitalRead(i*2+4)==current[i]){
      if(j>25){ result = true; break; }
      delay(1);
      ++j;
    }
    if(i==0) {
      Serial.print("check: ");
      Serial.println(result ? i+1 : -i-1);
    }
    delay(1);
  }
}
