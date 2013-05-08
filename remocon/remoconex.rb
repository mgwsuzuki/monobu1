# -*- coding: utf-8 -*-
require 'serialport'

$serial_port = '/dev/ttyS35';
$serlal_baudrate = 9600;
$serial_databit = 8;
$serial_stopbit = 1;
$serial_paritycheck = 0;
$serial_delimiter = "\n";

sp = SerialPort.new($serial_port,
                    $serial_baudrate,
                    $serial_databit,
                    $serial_stopbit,
                    $serial_paritycheck);

sp.read_timeout = 1000;

# 信号の補正(ボードM, 1用)
def adjust1(a)
  for n in 0..a.length-1
    if (n & 1) == 0
      a[n] -= 5;
    else
      a[n] += 5;
    end
  end
  a;
end

# 信号の補正(ボード2,3,4,5用)
def adjust2(a)
  for n in 0..a.length-1
    if (n & 1) == 0
      a[n] -= 4;
    else
      a[n] += 4;
    end
  end
  a;
end

#COMPORT接続後数秒はコマンドを受け付けないからsleepする
sleep 3;

# 点灯コマンド
turnon = [350, 174,
          45,  41,  46,  41,  44, 131,  46, 129,  48,  38,  48, 126,  49,  38,  48, 38,
          48,  38,  46, 128,  49,  38,  46,  41,  48, 126,  48,  38,  49, 126,  48, 38,
          49, 126,  48,  38,  48,  38,  49, 126,  49,  38,  48,  38,  48,  38,  48, 38,
          48,  38,  48,  38,  48, 126,  49, 126,  49, 126,  48, 126,  49,  38,  48, 38,
          49, 126,  49,  38,  51, 124,  51,  36,  49, 126,  49, 126,  48,  38,  52, 35, 52, 1000];

# 信号タイミングの補正
# IRRXコマンドで取得した値をそのまま使う場合に補正する
# ボード番号M,1はadjust1(), 2,3,4,5はadjust2()を使用する
turnon = adjust1(turnon);

# 消灯コマンド
turnoff = [355, 170,
           48,  38,  48,  38, 49, 126, 49, 126, 49,  38, 49, 126, 51,  36, 49, 38,
           48,  38,  48, 126, 52,  36, 51,  35, 52, 124, 51,  36, 51, 124, 52, 35,
           51, 124,  51,  35, 52,  35, 52, 124, 51,  36, 51,  35, 51,  35, 52, 35,
           52, 123,  52, 124, 51, 123, 52, 124, 51, 123, 52, 124, 51,  35, 52, 35,
           52,  35,  52, 123, 52, 123, 52,  35, 51, 124, 51, 124, 52,  35, 52, 35, 52, 1000];

# 信号タイミングの補正
# IRRXコマンドで取得した値をそのまま使う場合に補正する
# ボード番号M,1はadjust1(), 2,3,4,5はadjust2()を使用する
turnoff = adjust1(turnoff);

# turnonコマンドを作る
# 最後の0は終端を意味する
cmdon = "WTBL " + turnon.join(' ') + " 0";

# 念のためコンソールへ出力
p cmdon;

# テーブル書込
sp.puts cmdon;

# 書き込んだテーブルを読出しと表示
sp.puts "RTBL";
p sp.gets

# 赤外LEDから送信する
sp.puts "IRTX";

sleep 3

# turnoffコマンドを作る
# 最後の0は終端を意味する
cmdoff = "WTBL " + turnoff.join(' ') + " 0";

# 念のためコンソールへ出力
p cmdoff;

# テーブル書込
sp.puts cmdoff;

# 書き込んだテーブルを読み出す
sp.puts "RTBL";
p sp.gets

# 赤外LEDから送信する
sp.puts "IRTX";

# 2秒おきに点灯, 消灯, ボタン0状態読出し, ボタン1状態読出しを繰り返す
while 1 do
  p "tx cmdon"
  sp.puts cmdon
  sp.puts "IRTX"
  sleep 2
  p "tx cmdoff"
  sp.puts cmdoff
  sp.puts "IRTX"
  sleep 2
  p "read psw0"
  sp.puts "RPSW 0"
  p sp.gets
  p "read psw1"
  sp.puts "RPSW 1"
  p sp.gets
  p "read cds"
  sp.puts "RCDS"
  p sp.gets
end
