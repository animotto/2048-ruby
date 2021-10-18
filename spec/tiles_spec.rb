# frozen_string_literal: true

require 'game_2048/tiles'

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
        items = Array.new(SIZE) { rand(0..999) }
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
      items = Array.new(SIZE) { rand(0..999) }
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
    tiles = Tiles.new
    expect(tiles.game_over?).to be_falsey
    expect(tiles.win?).to be_falsey

    items = [
      2, 4, 8, 4,
      4, 2, 4, 2,
      8, 4, 2, 8,
      4, 2, 8, 4
    ]
    tiles = Tiles.new(items)
    expect(tiles.game_over?).to be_truthy
    expect(tiles.win?).to be_falsey

    items = [
      32, 32, 8, 4,
      4, 512, 16, 128,
      8, 2048, 0, 8,
      4, 64, 32, 64
    ]
    tiles = Tiles.new(items)
    expect(tiles.game_over?).to be_falsey
    expect(tiles.win?).to be_truthy
  end

  it 'Moves up'
  it 'Moves down'
  it 'Moves right'
  it 'Moves left'
end
