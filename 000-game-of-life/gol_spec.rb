require 'rspec'

class Cell
  attr_accessor :world, :x, :y

  def initialize(world, x=0, y=0)
    @world = world
    @x = x
    @y = y
    world.cells << self
  end

  def die!
    world.cells -= [self]
  end

  def dead?
    !world.cells.include?(self)
  end

  def alive?
    world.cells.include?(self)
  end

  def neighbours
    @neighbours = []
    world.cells.each do |cell|
      # Has a cell to the north
      if self.x == cell.x && self.y == cell.y - 1
        @neighbours << cell
      end

      # Has a cell to the north east
      if self.x == cell.x - 1 && self.y == cell.y - 1
        @neighbours << cell
      end

      # Has a cell to the west
      if self.x == cell.x + 1 && self.y == cell.y
        @neighbours << cell
      end

      if self.x == cell.x - 1 && self.y == cell.y
        @neighbours << cell
      end
    end

    @neighbours
  end

  def spawn_at(x, y)
    Cell.new(world, x, y)
  end
end

class World
  attr_accessor :cells

  def initialize
    @cells = []
  end

  def tick!
    cells.each do |cell|
      if cell.neighbours.count < 2
        cell.die!
      end
    end
  end
end


describe 'game of life' do
  let(:world) { World.new }
  context "cell utility methods" do
    subject { Cell.new(world) }
    it "spawn relative to" do
      cell = subject.spawn_at(3,5)
      cell.is_a?(Cell).should be_true
      cell.x.should == 3
      cell.y.should == 5
      cell.world.should == subject.world
    end

    it "detects a neighbour to the north" do
      cell = subject.spawn_at(0, 1)
      subject.neighbours.count.should == 1
    end

    it "detects a neighbour to the north east" do
      cell = subject.spawn_at(1, 1)
      subject.neighbours.count.should == 1
    end

    it "detects a neighbour to the left" do
      cell = subject.spawn_at(-1, 0)
      subject.neighbours.count.should == 1
    end

    it "detects a neighbour to the right" do
      cell = subject.spawn_at(1, 0)
      subject.neighbours.count.should == 1
    end

    it "dies" do
      subject.die!
      subject.world.cells.should_not include(subject)
    end
  end

  it "Rule #1: Any live cell with fewer than two live neighbours dies, as if caused by under-population." do
    cell = Cell.new(world)
    new_cell = cell.spawn_at(2,0)
    world.tick!
    cell.should be_dead
  end

  it "Rule #2: Any live cell with two or three live neighbours lives on to the next generation." do
    cell = Cell.new(world)
    new_cell = cell.spawn_at(1,0)
    other_new_cell = cell.spawn_at(-1, 0)
    world.tick!
    cell.should be_alive
  end
end
