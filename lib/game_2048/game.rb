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
      @render.refresh

      Kernel.trap('SIGWINCH') do
        @render.refresh
      end

      while @running
        @render.draw
        key = @terminal.read
        case key
        when 'q'
          stop
        when 'r'
          @tiles.reset
        when '+'
          @render.size += 1
          @render.refresh
        when '-'
          @render.size -= 1
          @render.refresh
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
        when 'u'
          @tiles.undo
        end
      end

      @terminal.cooked_mode
      @terminal.erase_display
      @terminal.show_cursor
      @terminal.move_home
    end
  end
end
