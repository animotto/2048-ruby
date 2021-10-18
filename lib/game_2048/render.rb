# frozen_string_literal: true

module Game2048
  ##
  # Render
  class Render
    SIZE = 3
    HORIZONTAL = "\u2500"
    VERTICAL = "\u2502"
    LEFT_VERTICAL = "\u251c"
    RIGHT_VERTICAL = "\u2524"
    TOP_HORIZONTAL = "\u252c"
    BOTTOM_HORIZONTAL = "\u2534"
    TOP_LEFT = "\u250c"
    TOP_RIGHT = "\u2510"
    BOTTOM_LEFT = "\u2514"
    BOTTOM_RIGHT = "\u2518"
    HORIZONTAL_VERTICAL = "\u253c"
    BORDER_COLOR = :yellow
    TILE_COLOR = :cyan
    STATUSBAR_COLOR = :blue
    STATUSBAR_TEXT_COLOR = :white
    GAMEOVER_COLOR = :red
    WIN_COLOR = :green
    BLANK = ' '

    attr_reader :size

    def initialize(terminal, tiles, **options)
      @tiles = tiles
      @terminal = terminal
      @x = @y = 1
      @rows = @cols = 0
      @width = @height = 0
      @size = options.fetch(:size, SIZE)
    end

    def size=(value)
      n = Math.sqrt(Tiles::SIZE).to_i
      width = value * 2 * n + n + 1
      height = value * n + n + 1
      return if value <= 1 || width > @cols || height > @rows

      @size = value
    end

    def refresh
      @terminal.erase_display
      align
      draw
    end

    def draw
      draw_tiles
      draw_statusbar
      draw_gameover
    end

    def draw_statusbar
      line = String.new
      line << "#{@tiles.score} #{VERTICAL} "
      line << "\u2190\u2193\u2191\u2192 Move #{VERTICAL} "
      line << "u Undo #{VERTICAL} "
      line << "r Reset #{VERTICAL} "
      line << "+- Scale #{VERTICAL} "
      line << 'q Quit'
      x = @cols / 2 - line.length / 2 + 1
      return if @cols < line.length

      @terminal.move_to(1, @rows)
      @terminal.bg_color(STATUSBAR_COLOR)
      @terminal.write(BLANK * @cols)
      @terminal.move_to(x, @rows)
      @terminal.fg_color(STATUSBAR_TEXT_COLOR)
      @terminal.write(line[0..(@cols - 1)])
      @terminal.reset
    end

    def draw_gameover
      y = @y + @height + 1
      return if @rows <= y

      @terminal.move_to(1, y)
      @terminal.write(BLANK * @cols)
      @terminal.reset

      line = String.new
      if @tiles.win?
        line << 'Win!'
      elsif @tiles.game_over?
        line << 'Game over!'
      end
      x = @cols / 2 - line.length / 2 + 1
      @terminal.move_to(x, y)
      @tiles.win? ? @terminal.fg_color(WIN_COLOR) : @terminal.fg_color(GAMEOVER_COLOR)
      @terminal.bold
      @terminal.write(line[0..(@cols - 1)])
      @terminal.reset
    end

    def draw_tiles
      n = Math.sqrt(Tiles::SIZE).to_i
      return if @cols <= @width || @rows <= @height

      @terminal.move_to(@x, @y)
      @terminal.fg_color(BORDER_COLOR)
      @terminal.write(TOP_LEFT)
      n.times do |i|
        @terminal.write(HORIZONTAL * (@size * 2))
        next if i == n - 1

        @terminal.write(TOP_HORIZONTAL)
      end
      @terminal.write(TOP_RIGHT)

      n.times do |i|
        @size.times do |j|
          @terminal.move_to(@x, @y + i * @size + i + j + 1)
          @terminal.write(VERTICAL)
          n.times do |k|
            @terminal.reset
            @terminal.write(BLANK * (@size * 2))
            @terminal.reset
            next if k == n - 1

            @terminal.fg_color(BORDER_COLOR)
            @terminal.write(VERTICAL)
          end
          @terminal.fg_color(BORDER_COLOR)
          @terminal.write(VERTICAL)
        end
        next if i == n - 1

        @terminal.move_to(@x, @y + i * (@size + 1) + @size + 1)
        @terminal.write(LEFT_VERTICAL)
        n.times do |j|
          @terminal.write(HORIZONTAL * (@size * 2))
          next if j == n - 1

          @terminal.write(HORIZONTAL_VERTICAL)
        end
        @terminal.write(RIGHT_VERTICAL)
      end

      @terminal.move_to(@x, @y + @size * n + n)
      @terminal.write(BOTTOM_LEFT)
      n.times do |i|
        @terminal.write(HORIZONTAL * (@size * 2))
        next if i == n - 1

        @terminal.write(BOTTOM_HORIZONTAL)
      end
      @terminal.write(BOTTOM_RIGHT)
      @terminal.reset

      @terminal.fg_color(TILE_COLOR)
      @terminal.bold
      @tiles.items.each.with_index do |tile, i|
        t = tile.zero? ? '' : tile.to_s
        x = i % n * (@size * 2 + 1) + @size - t.length / 2 + 1
        y = i / n * (@size + 1) + @size / 2 + 1
        @terminal.move_to(@x + x, @y + y)
        @terminal.write(t)
      end
      @terminal.reset
    end

    def align
      @rows, @cols = @terminal.display_size
      n = Math.sqrt(Tiles::SIZE).to_i
      @width = @size * 2 * n + n + 1
      @height = @size * n + n + 1
      @x = @cols / 2 - @width / 2
      @y = @rows / 2 - @height / 2
    end
  end
end
