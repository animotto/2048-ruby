# frozen_string_literal: true

require 'securerandom'

module Game2048
  ##
  # Game
  class Tiles
    SIZE = 4**2
    NO_TILE = 0
    NEW_TILE_CHANCE = 90
    NEW_TILE_2 = 2
    NEW_TILE_4 = 4
    WIN_SUM = 2048

    attr_reader :items

    def initialize(items = nil, auto_new_tile: true)
      raise TilesError, "Tile map size must be #{SIZE}" if !items.nil? && items.length != SIZE

      if items.nil?
        reset
      else
        @items = items
      end
      @auto_new_tile = auto_new_tile
      @items_prev = []
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

      @items[items.sample] = SecureRandom.rand(1..100) <= NEW_TILE_CHANCE ? NEW_TILE_2 : NEW_TILE_4
    end

    def game_over?
      return false if @items.index(NO_TILE)

      n = Math.sqrt(SIZE).to_i
      @items.each.with_index do |item, i|
        a = i + 1
        return false if a < @items.length && !(a % n).zero? && item == @items[a]

        b = i + n
        return false if b < @items.length && item == @items[b]
      end
      true
    end

    def win?
      items.count { |item| item >= WIN_SUM } >= 1
    end

    def undo
      return if @items_prev.empty?

      @items = @items_prev.dup
      @items_prev.clear
    end

    def move_up
      items = @items.dup
      n = Math.sqrt(SIZE).to_i
      n.times do |row|
        move_zeroes(-n)
        n.times do |column|
          tile = row * n + column
          tile_prev = tile - n
          if !tile_prev.negative? && @items[tile_prev] == @items[tile]
            @items[tile_prev] += @items[tile]
            @items[tile] = NO_TILE
          end
        end
        move_zeroes(-n)
      end
      return if items == @items

      @items_prev = items
      new_tile if @auto_new_tile
    end

    def move_down
      items = @items.dup
      n = Math.sqrt(SIZE).to_i
      (n - 1).downto(0) do |row|
        move_zeroes(n)
        n.times do |column|
          tile = row * n + column
          tile_next = tile + n
          if tile_next < @items.length && @items[tile_next] == @items[tile]
            @items[tile_next] += @items[tile]
            @items[tile] = NO_TILE
          end
        end
        move_zeroes(n)
      end
      return if items == @items

      @items_prev = items
      new_tile if @auto_new_tile
    end

    def move_right
      items = @items.dup
      n = Math.sqrt(SIZE).to_i
      n.times do |row|
        move_zeroes(1)
        (n - 1).downto(0) do |column|
          tile = row * n + column
          tile_next = tile + 1
          if tile_next < row * n + n && @items[tile_next] == @items[tile]
            @items[tile_next] += @items[tile]
            @items[tile] = NO_TILE
          end
        end
        move_zeroes(1)
      end
      return if items == @items

      @items_prev = items
      new_tile if @auto_new_tile
    end

    def move_left
      items = @items.dup
      n = Math.sqrt(SIZE).to_i
      n.times do |row|
        move_zeroes(-1)
        n.times do |column|
          tile = row * n + column
          tile_prev = tile - 1
          if tile_prev >= row * n && @items[tile_prev] == @items[tile]
            @items[tile_prev] += @items[tile]
            @items[tile] = NO_TILE
          end
        end
        move_zeroes(-1)
      end
      return if items == @items

      @items_prev = items
      new_tile if @auto_new_tile
    end

    private

    def move_zeroes(dir)
      n = Math.sqrt(SIZE).to_i
      n.times do |row|
        n.times do |column|
          tile = row * n + column
          loop do
            tile_other = tile + dir
            if tile_other.negative? || tile_other >= @items.length || (dir == 1 && tile_other >= row * n + n) || (dir == -1 && tile_other < row * n) || @items[tile_other] != NO_TILE
              break
            end

            @items[tile_other] = @items[tile]
            @items[tile] = NO_TILE
            tile = tile_other
          end
        end
      end
    end
  end

  class TilesError < StandardError; end
end
