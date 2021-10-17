# frozen_string_literal: true

module Game2048
  ##
  # Game
  class Tiles
    SIZE = 4**2
    NO_TILE = 0
    NEW_TILE_CHANCE = 90
    NEW_TILE_2 = 2
    NEW_TILE_4 = 4

    attr_reader :items

    def initialize(items = nil)
      raise GameError, "Tile map size must be #{SIZE}" if !items.nil? && items.length != SIZE

      if items.nil?
        reset
      else
        @items = items
      end
    end

    def score
      @items.sum
    end

    def reset
      @items = Array.new(SIZE, NO_TILE)
      new_tile
    end

    def new_tile
      items = []
      @items.each.with_index { |tile, i| items << i if tile == NO_TILE }
      return if items.empty?

      @items[items.sample] = Kernel.rand(1..100) <= NEW_TILE_CHANCE ? NEW_TILE_2 : NEW_TILE_4
    end

    def move_up
      items = @items.dup
      3.times do |i|
        n = i * 4 + 4
        3.times do |j|
          a = n + j
          move(a, -4)
        end
      end
      new_tile if items != @items
    end

    def move_down
      items = @items.dup
      2.downto(0) do |i|
        n = i * 4
        4.times do |j|
          a = n + j
          move(a, 4)
        end
      end
      new_tile if items != @items
    end

    def move_right
      items = @items.dup
      3.times do |i|
        4.times do |j|
          a = i + j * 4
          move(a, 1)
        end
      end
      new_tile if items != @items
    end

    def move_left
      items = @items.dup
      2.downto(0) do |i|
        n = i + 1
        4.times do |j|
          a = n + j * 4
          move(a, -1)
        end
      end
      new_tile if items != @items
    end

    private

    def move(a, b)
      c = a + b
      return if c.negative? || c >= @items.length || (b == 1 && (c % 4).zero?) || (b == -1 && ((c + 1) % 4).zero?)

      if @items[c] == @items[a]
        @items[c] += @items[a]
        @items[a] = NO_TILE
        move(c, b)
      elsif @items[c] == NO_TILE
        @items[c] = @items[a]
        @items[a] = NO_TILE
        move(c, b)
      end
    end
  end

  class GameError < StandardError; end
end