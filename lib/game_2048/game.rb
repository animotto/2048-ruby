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
      terminal_init

      Kernel.trap('SIGWINCH') do
        @render.refresh
      end

      Kernel.trap('SIGCONT') do
        terminal_init
      end

      while @running
        @render.draw
        key = @terminal.read

        case key
        when 'q', :ctrl_c
          stop
        when :ctrl_l
          @render.refresh
        when :ctrl_z
          terminal_clear
          Process.kill('SIGSTOP', Process.pid)
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

      terminal_clear
    end

    private

    def terminal_init
      @terminal.raw_mode
      @terminal.alt_screen_on
      @terminal.hide_cursor
      @render.refresh
    end

    def terminal_clear
      @terminal.cooked_mode
      @terminal.alt_screen_off
      @terminal.show_cursor
    end
  end
end
