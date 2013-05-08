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

# リモコン操作までにタイムアウトしないように長めにしておく
sp.read_timeout = 5000;

# COMPORT接続後数秒はコマンドを受け付けないからsleepする
sleep 3;

# IRRXコマンドを発行してレスポンスを待つ
sp.puts "IRRX";
p "push remocon button";
rxsig = sp.gets;

# 行末の改行コードを削除する
rxsig.chomp!;

# 受信した文字列をそのまま表示する
p rxsig;

# 空白区切りからカンマ区切りにして表示する
p rxsig.split(/\s/).join(',');
