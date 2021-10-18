# frozen_string_literal: true

require 'game_2048/terminal'
require 'stringio'
require 'securerandom'

include Game2048

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

def clear_buffer(buffer)
  buffer.string.clear
  buffer.rewind
end

RSpec.describe Terminal do
  input = StringIO.new
  output = StringIO.new
  terminal = Terminal.new(input: input, output: output)

  it 'Moves the cursor to specific rows/columns' do
    100.times do
      clear_buffer(output)
      x = SecureRandom.rand(-999..999)
      y = SecureRandom.rand(-999..999)
      terminal.move_to(x, y)
      expect(output.string).to eq("\e[#{y};#{x}H")
    end
  end

  it 'Moves the cursor to the top left position' do
    clear_buffer(output)
    terminal.move_home
    expect(output.string).to eq("\e[1;1H")
  end

  it 'Erases display' do
    clear_buffer(output)
    terminal.erase_display
    expect(output.string).to eq("\e[2J")
  end

  it 'Sets foreground color' do
    COLORS.each do |k, v|
      clear_buffer(output)
      terminal.fg_color(k)
      terminal.write
      expect(output.string).to eq("\e[#{v + 30}m")
    end

    clear_buffer(output)
    expect { terminal.fg_color(:unknown_color) }.to raise_error(TerminalError)
  end

  it 'Sets background color' do
    COLORS.each do |k, v|
      clear_buffer(output)
      terminal.bg_color(k)
      terminal.write
      expect(output.string).to eq("\e[#{v + 40}m")
    end

    clear_buffer(output)
    expect { terminal.fg_color(:unknown_color) }.to raise_error(TerminalError)
  end

  it 'Sets the bold style' do
    clear_buffer(output)
    terminal.bold
    terminal.write
    expect(output.string).to eq("\e[1m")
  end

  it 'Sets the underscore style' do
    clear_buffer(output)
    terminal.underscore
    terminal.write
    expect(output.string).to eq("\e[4m")
  end

  it 'Sets the dim style' do
    clear_buffer(output)
    terminal.dim
    terminal.write
    expect(output.string).to eq("\e[2m")
  end

  it 'Sets the blinking style' do
    clear_buffer(output)
    terminal.blink
    terminal.write
    expect(output.string).to eq("\e[5m")
  end

  it 'Sets the reverse style' do
    clear_buffer(output)
    terminal.reverse
    terminal.write
    expect(output.string).to eq("\e[7m")
  end

  it 'Resets all attributes' do
    clear_buffer(output)
    terminal.reset
    expect(output.string).to eq("\e[0m")
  end

  it 'Hides cursor' do
    clear_buffer(output)
    terminal.hide_cursor
    expect(output.string).to eq("\e[?25l")
  end

  it 'Shows cursor' do
    clear_buffer(output)
    terminal.show_cursor
    expect(output.string).to eq("\e[?25h")
  end

  it 'Determines the display size' do
    100.times do
      clear_buffer(input)
      clear_buffer(output)
      rows = SecureRandom.rand(-999..999)
      cols = SecureRandom.rand(-999..999)
      input.write("\e[#{rows};#{cols}R")
      input.rewind
      r_rows, r_cols = terminal.display_size
      expect(output.string).to eq("\e[999;999H\e[6n")
      expect(r_rows).to eq(rows)
      expect(r_cols).to eq(cols)
    end
  end

  it 'Writes text to the terminal with attributes' do
    clear_buffer(output)
    terminal.write('foobar')
    expect(output.string).to eq('foobar')

    clear_buffer(output)
    terminal.bold
    terminal.fg_color(:red)
    terminal.bg_color(:white)
    terminal.write('foobar')
    expect(output.string).to eq("\e[1;31;47mfoobar")
  end

  it 'Reads a key from the terminal' do
    keys =
      ('0'..'9').to_a +
      ('a'..'z').to_a +
      ('A'..'Z').to_a
    keys.each do |key|
      clear_buffer(input)
      clear_buffer(output)
      input.write(key)
      input.rewind
      expect(terminal.read).to eq(key)
    end

    keys = {
      up: "\e[A",
      down: "\e[B",
      right: "\e[C",
      left: "\e[D"
    }
    keys.each do |k, v|
      clear_buffer(input)
      clear_buffer(output)
      input.write(v)
      input.rewind
      expect(terminal.read).to eq(k)
    end
  end
end
