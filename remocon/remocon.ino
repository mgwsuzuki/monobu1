// -*- c++ -*-

////////////////////////////////////////////////////////////
////
//// リモコン
////

#include "SerialCmd.h"

//// LED
int led = 13;
int ledstate = 0;

//// 赤外LED
int irtx = 2;

//// 赤外受信モジュール
int irrx = 3;

//// push sw
int psw1 = 12;
int psw2 = 13;

//// cds
int cds = 0;

//// タイミング用配列
#define TIMING_TABLE_SIZE 256
uint16_t timing_table[TIMING_TABLE_SIZE];
uint16_t timing_table_size = 0;

//// 引数がある場合のコマンド関数の例
void cmdLEDS(){
  int a = Serial.parseInt();
  if (a == 0){
    digitalWrite(led, LOW);
    digitalWrite(irtx, LOW);
    ledstate = 0;
  }else if (a == 1){
    digitalWrite(led, HIGH);
    digitalWrite(irtx, HIGH);
    ledstate = 1;
  }
}

//// タイミング用配列にデータを書き込む
//// 0の値を入力したら終了する
void cmdWTBL(){

  int a;
  timing_table_size = 0;
  while(1){
    a = Serial.parseInt();
    // 入力値が0なら終了
    if (a == 0){
      break;
    }
    timing_table[timing_table_size++] = a;
    // テーブルサイズをオーバーしないようにする
    if (timing_table_size == TIMING_TABLE_SIZE){
      break;
    }
  }
}

//// タイミング用配列の内容を返す
void cmdRTBL(){

  uint16_t n;
  if (timing_table_size == 0){
    Serial.print("");
    return;
  }

  for (n = 0; n < timing_table_size-1; n++){
    Serial.print(timing_table[n], DEC);
    Serial.print(" ");
  }
  Serial.print(timing_table[n], DEC);
  Serial.print("\n");
}

//// 送信コマンド
void cmdIRTX(){
  IRTransmit();
}

//// 受信コマンド
void cmdIRRX(){

  int n;

  // 信号を待ち受ける
  IrReceive();

  // 受信した信号をUARTに出力する
  cmdRTBL();
}

//// timing_tableの値にそって信号を送信する
void IRTransmit(){
  for (int n = 0; n < timing_table_size; n++){
    uint32_t len = timing_table[n] * 10;
    uint32_t us = micros();
    do {
      digitalWrite(irtx, (n & 1 ? 0 : 1));
      delayMicroseconds(8);
      digitalWrite(irtx, 0);
      delayMicroseconds(7);
    }while(long(us + len - micros()) > 0);
  }

  // 必ず赤外LEDを停止する
  digitalWrite(irtx, 0);
}

//// 信号を待ち受けてtiming_tableに記録する
//// リモコンモジュールの出力が反転していることに注意
//// 赤外光があるときには0, ないときには1がピンに入力される
#define IR_HIGH 0
#define IR_LOW  1
void IrReceive(){

  uint32_t prev;
  uint32_t now;
  int n = 0;
  uint8_t level;

  //// 赤外光を検出するまで待つ
  while(digitalRead(irrx) != IR_HIGH){}
  prev = micros();

  //// 待ち受ける信号レベル
  //// IR_LOW:  H -> Lになるのを待つ
  //// IR_HIGH: L -> Hになるのを待つ
  level = IR_LOW;

  while(n < TIMING_TABLE_SIZE){
    while(digitalRead(irrx) != level){}
    now = micros();
    timing_table[n++] = (now - prev + 5) / 10;
    prev = now;
    level ^= 1;				// 待ち受ける信号レベルを反転する
  }
  timing_table_size = TIMING_TABLE_SIZE;
}

//// cdsの値を返す
//// 5回読み出す
void cmdRCDS(){
  int adin;
  for (int n = 0; n < 4; n++){
    adin = analogRead(cds);
    Serial.print(adin, DEC);
    Serial.print(" ");
  }
  adin = analogRead(cds);
  Serial.print(adin, DEC);
  Serial.print("\n");
}

//// push swの状態を返す
//// コマンドフォーマット:
//// RPSW 0 または
//// RPSW 1
void cmdRPSW(){
  int arg = Serial.parseInt();
  int sw;
  if (arg == 0){
    sw = !digitalRead(psw1);
  }else if (arg == 1){
    sw = !digitalRead(psw2);
  }else{
    sw = -1;
  }
  Serial.print(sw, DEC);
  Serial.print("\n");
}

void setup(){
  // シリアルの初期化
  Serial.begin(9600);

  // コマンド関数の追加
  SerialCmd.AddCmd("IRTX", cmdIRTX);
  SerialCmd.AddCmd("IRRX", cmdIRRX);
  SerialCmd.AddCmd("WTBL", cmdWTBL);
  SerialCmd.AddCmd("RTBL", cmdRTBL);
  SerialCmd.AddCmd("RCDS", cmdRCDS);
  SerialCmd.AddCmd("RPSW", cmdRPSW);

  // LEDのpin設定
  pinMode(led, OUTPUT);

  // 赤外LEDと受信モジュールの設定
  pinMode(irtx, OUTPUT);
  pinMode(irrx, INPUT);

  // push swの設定
  pinMode(psw1, INPUT_PULLUP);
  pinMode(psw2, INPUT_PULLUP);
  
}

void loop(){
  SerialCmd.Task();
}
