# -*- coding: utf-8 -*-
# 信号を学習するのではなくて、データから信号パタンを生成する
#
require '../irshield'

# ポート名は適当に変更すること
shield = IRShield.new(read_timeout: 5000, port: "/dev/ttyS35")

# 接続待ち
puts "wait connection"
shield.wait_connection

# 送信データ
tx_pon  = [0x34, 0x4a, 0x90, 0x3c, 0xac];
tx_poff = [0x34, 0x4a, 0x90, 0xfc, 0x6c];
tx_inc  = [0x34, 0x4a, 0x90, 0x5c, 0xcc];
tx_dec  = [0x34, 0x4a, 0x90, 0xdc, 0x4c];
tx_up   = [0x34, 0x4a, 0x90, 0xbc, 0x2c];
tx_down = [0x34, 0x4a, 0x90, 0x7c, 0xec];

puts "adjust minute"
p t = shield.encode(tx_inc, 38, :AEHA)
shield.wtbl(t)
p shield.rtbl
shield.irtx
sleep 1

puts "up"
p t = shield.encode(tx_up, 38, :AEHA)
shield.wtbl(t)
p shield.rtbl
shield.irtx
sleep 1
shield.irtx
sleep 1

puts "down"
p t = shield.encode(tx_down, 38, :AEHA)
shield.wtbl(t)
p shield.rtbl
shield.irtx
sleep 1
shield.irtx
sleep 1

puts "end"
p t = shield.encode(tx_pon, 38, :AEHA)
shield.wtbl(t)
p shield.rtbl
shield.irtx
