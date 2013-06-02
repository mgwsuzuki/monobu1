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
# 前半4byteは固定数値、後半4byteは表示したい文字のアスキーコード
tx_1234 = [0x34, 0x4a, 0x91, 0x01, 0x31, 0x32, 0x33, 0x34];
tx_abcd = [0x34, 0x4a, 0x91, 0x01, 0x61, 0x62, 0x63, 0x64];

puts "put str 1234"
p t = shield.encode(tx_1234, 64, :AEHA)
shield.wtbl(t)
p shield.rtbl
shield.irtx
sleep 12

puts "put str abcd"
p t = shield.encode(tx_abcd, 64, :AEHA)
shield.wtbl(t)
p shield.rtbl
shield.irtx
sleep 1
