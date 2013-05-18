# coding: utf-8
require 'serialport'

class IRShield
  READ_TIMEOUT = 1000

  ORANGE_BUTTON = 0
  BLACK_BUTTON  = 1

  attr_accessor :options, :sp

  def default_options
    {
      port: '/dev/cu.usbmodemfd121',
      baudrate: 9600,
      databit:     8,
      stopbit:     1,
      paritycheck: 0,
      delimiter: "\n"
    }
  end

  def initialize(options = {})
    self.options = default_options.merge options
    self.sp = SerialPort.new *self.options.values_at(:port, :baudrate, :databit, :stopbit, :paritycheck)
    self.sp.read_timeout = options[:read_timeout] || self.class::READ_TIMEOUT
  end

  def wait_connection
    sleep 3
  end

  def wtbl(timings)
    cmd "WTBL #{timings.join ' '} 0"
  end

  def irtx
    cmd "IRTX"
  end

  def irrx
    cmd 'IRRX'
    adjust get_ints
  end

  def irrx_first
    timings = irrx

    return [] if timings.empty?

    # 無信号区間の長さは桁が違うぐらい長いようなのでそれを頼りに最初のコマンドを切り出す
    no_signal_len = timings.max.to_s.length
    timings.take_while {|x| x.to_s.length < no_signal_len } << 1000
  end

  def rtbl
    cmd "RTBL"
    get_ints
  end

  def rcds
    cmd "RCDS"
    get_ints
  end

  def rpsw
    cmd "RPSW"
    get_ints.first
  end

  def cmd(op)
    sp.puts op
  end

  def get_ints
    (sp.gets || "").chomp.split(/\s/).map(&:to_i)
  end

  def adjust(timings)
    timings.map {|timing| timing.even? ? timing - signal_delay : timing + signal_delay }
  end

  # Board 2,3,4,5用、M用はオーバーライドしてください
  def signal_delay
    4
  end
end
