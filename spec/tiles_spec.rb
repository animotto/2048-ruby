# frozen_string_literal: true

require 'game_2048/tiles'
require 'json'
require 'securerandom'

include Game2048

SIZE = 4**2

RSpec.describe Tiles do
  it 'Creates new Tiles instance' do
    expect { Tiles.new([]) }.to raise_error(TilesError)
    expect { Tiles.new([3, 5, 1]) }.to raise_error(TilesError)

    100.times do
      tiles = Tiles.new
      expect(tiles.items.length).to eq(SIZE)
      tile2 = tiles.items.count(2)
      tile4 = tiles.items.count(4)
      expect(tile2 ^ tile4).to eq(1)
      expect(tiles.items.count(0)).to eq(SIZE - 1)
    end
  end

  it 'Returns sum of score' do
    100.times do |i|
      if i.even?
        items = Array.new(SIZE) { SecureRandom.rand(0..999) }
        tiles = Tiles.new(items)
        expect(tiles.score).to eq(items.sum)
      else
        tiles = Tiles.new
        expect(tiles.score).to eq(tiles.items.sum)
      end
    end
  end

  it 'Resets tiles' do
    100.times do |i|
      items = Array.new(SIZE) { SecureRandom.rand(0..999) }
      tiles = i.even? ? Tiles.new(items) : Tiles.new
      tiles.reset
      tile2 = tiles.items.count(2)
      tile4 = tiles.items.count(4)
      expect(tile2 ^ tile4).to eq(1)
      expect(tiles.items.count(0)).to eq(SIZE - 1)
    end
  end

  it 'Adds new tile' do
    100.times do
      tiles = Tiles.new
      (SIZE - 1).times do |i|
        tiles.new_tile
        expect(tiles.items.count { |item| !item.zero? }).to eq(i + 2)
      end

      10.times do
        items = tiles.items.dup
        tiles.new_tile
        expect(items).to eq(tiles.items)
      end
    end
  end

  it 'Returns the state of the game' do
    items = JSON.parse(File.read('spec/tiles/game_state.json'))
    items.each do |item|
      tiles = Tiles.new(item['tiles'])
      expect(tiles.game_over?).to eq(item['game_over'])
      expect(tiles.win?).to eq(item['win'])
    end
  end

  it 'Moves up' do
    items = JSON.parse(File.read('spec/tiles/move_up.json'))

    items.each do |item|
      tiles = Tiles.new(item[0..15], auto_new_tile: false)
      tiles.move_up
      expect(tiles.items).to eq(item[16..31])
    end
  end

  it 'Moves down' do
    items = JSON.parse(File.read('spec/tiles/move_down.json'))

    items.each do |item|
      tiles = Tiles.new(item[0..15], auto_new_tile: false)
      tiles.move_down
      expect(tiles.items).to eq(item[16..31])
    end
  end

  it 'Moves right' do
    items = JSON.parse(File.read('spec/tiles/move_right.json'))

    items.each do |item|
      tiles = Tiles.new(item[0..15], auto_new_tile: false)
      tiles.move_right
      expect(tiles.items).to eq(item[16..31])
    end
  end

  it 'Moves left' do
    items = JSON.parse(File.read('spec/tiles/move_left.json'))

    items.each do |item|
      tiles = Tiles.new(item[0..15], auto_new_tile: false)
      tiles.move_left
      expect(tiles.items).to eq(item[16..31])
    end
  end

  it 'Undoes the last move' do
    100.times do
      tiles = Tiles.new

      items_prev = tiles.items.dup
      tiles.undo
      expect(tiles.items).to eq(items_prev)

      10.times do
        items_prev = tiles.items.dup
        case SecureRandom.rand(4)
        when 0
          tiles.move_up
        when 1
          tiles.move_down
        when 2
          tiles.move_right
        when 3
          tiles.move_left
        end
        tiles.undo
        expect(tiles.items).to eq(items_prev)
      end
    end
  end
end
