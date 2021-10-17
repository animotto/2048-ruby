# frozen_string_literal: true

module Game2048
  ##
  # Game
  class Game
    def initialize
      @terminal = Terminal.new
      @tiles = Tiles.new
      @render = Render.new(@terminal, @tiles)
      @running = false
    end

    def stop
      @running = false
    end

    def run
      @running = true
      @terminal.raw_mode
      @terminal.hide_cursor
      @terminal.erase_display
      @render.align

      Kernel.trap('SIGWINCH') do
        @terminal.erase_display
        @render.align
        @render.draw
      end

      while @running
        @render.draw
        key = @terminal.read
        case key
        when 'q'
          stop
        when 'r'
          @tiles.reset
        end

        next if @tiles.win? || @tiles.game_over?

        case key
        when :up
          @tiles.move_up
        when :down
          @tiles.move_down
        when :right
          @tiles.move_right
        when :left
          @tiles.move_left
        end
      end

      @terminal.cooked_mode
      @terminal.erase_display
      @terminal.show_cursor
      @terminal.move_home
    end
  end
end
