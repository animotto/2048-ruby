# frozen_string_literal: true

module Game2048
  ##
  # VT100 terminal
  class Terminal
    CSI = "\e["
    CUU = 'A'
    CUD = 'B'
    CUF = 'C'
    CUB = 'D'
    CUP = 'H'
    ED = 'J'
    SGR = 'm'

    RESET = 0
    BOLD = 1
    DIM = 2
    BLINK = 5
    REVERSE = 7
    UNDERSCORE = 4
    COLOR_FG = 30
    COLOR_BG = 40

    COLORS = {
      black: 0,
      red: 1,
      green: 2,
      yellow: 3,
      blue: 4,
      magenta: 5,
      cyan: 6,
      white: 7
    }.freeze

    def initialize(input: $stdin, output: $stdout)
      @intput = input
      @output = output
      @sgr = []
    end

    def move_to(x, y)
      @output.write("#{CSI}#{y};#{x}#{CUP}")
    end

    def move_home
      move_to(1, 1)
    end

    def erase_display
      @output.write("#{CSI}2#{ED}")
    end

    def fg_color(color)
      color_exist?(color)
      @sgr << COLORS[color] + COLOR_FG
    end

    def bg_color(color)
      color_exist?(color)
      @sgr << COLORS[color] + COLOR_BG
    end

    def bold
      @sgr << BOLD
    end

    def underscore
      @sgr << UNDERSCORE
    end

    def dim
      @sgr << DIM
    end

    def blink
      @sgr << BLINK
    end

    def reverse
      @sgr << REVERSE
    end

    def reset
      @sgr.clear
      @output.write("#{CSI}#{RESET}#{SGR}")
    end

    def write(text)
      text = "#{CSI}#{@sgr.join(';')}#{SGR}#{text}" unless @sgr.empty?
      @sgr.clear
      @output.write(text)
    end

    private

    def color_exist?(color)
      raise TerminalError, "Unknown color #{color}" unless COLORS.key?(color)

      true
    end
  end

  class TerminalError < StandardError; end
end
