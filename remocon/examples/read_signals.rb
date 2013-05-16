# coding: utf-8
require '../irshield'

# timeoutをながくする
shield = IRShield.new(read_timeout: 5000)

#COMPORT接続後数秒はコマンドを受け付けないからsleepする
puts "wait connection"
shield.wait_connection

puts "push button!"
loop {
  cmd = shield.irrx_first
  p cmd unless cmd.empty?
}
