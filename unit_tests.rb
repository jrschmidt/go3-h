

require '~/Desktop/go3/go3'


require 'test/unit'


class Go3Test < Test::Unit::TestCase

  def app
    Sinatra::Application
  end

  # Tests Part One - Board Point and Stone Methods

  def test_valid_point
    game = Game.new
    board = game.board
    assert board.valid_point?([1,1])
    assert board.valid_point?([1,4])
    assert board.valid_point?([1,6])
    assert board.valid_point?([2,1])
    assert board.valid_point?([2,7])
    assert board.valid_point?([3,8])
    assert board.valid_point?([4,9])
    assert board.valid_point?([5,10])
    assert board.valid_point?([6,11])
    assert board.valid_point?([9,4])
    assert board.valid_point?([11,6])
    assert board.valid_point?([11,11])
    assert_equal board.valid_point?([0,0]), false
    assert_equal board.valid_point?([0,1]), false
    assert_equal board.valid_point?([0,5]), false
    assert_equal board.valid_point?([0,8]), false
    assert_equal board.valid_point?([1,0]), false
    assert_equal board.valid_point?([1,7]), false
    assert_equal board.valid_point?([1,11]), false
    assert_equal board.valid_point?([3,9]), false
    assert_equal board.valid_point?([3,12]), false
    assert_equal board.valid_point?([4,10]), false
    assert_equal board.valid_point?([5,11]), false
    assert_equal board.valid_point?([8,0]), false
    assert_equal board.valid_point?([9,1]), false
    assert_equal board.valid_point?([9,3]), false
    assert_equal board.valid_point?([11,5]), false
    assert_equal board.valid_point?([12,1]), false
    assert_equal board.valid_point?([14,6]), false
  end

  def test_get_point
    game = Game.new
    points = game.board.points
    assert_equal points.get_point([1,1]), :empty
    assert_equal points.get_point([6,1,]), :empty
    assert_equal points.get_point([3,5]), :empty
    assert_equal points.get_point([1,6]), :empty
    assert_equal points.get_point([9,4]), :empty
    assert_equal points.get_point([8,11]), :empty
  end

  def test_set_point
    game = Game.new
    board = game.board
    points = board.points

    board.set_point([4,4], :red)
    board.set_point([9,9], :red)
    board.set_point([4,6], :white)
    board.set_point([2,3], :white)
    board.set_point([5,9], :blue)
    board.set_point([3,4], :blue)
    assert_equal  points.get_point([4,4]), :red
    assert_equal  points.get_point([9,9]), :red
    assert_equal  points.get_point([4,6]), :white
    assert_equal  points.get_point([2,3]), :white
    assert_equal  points.get_point([5,9]), :blue
    assert_equal  points.get_point([3,4]), :blue
    assert_equal  points.get_point([3,3]), :empty
    assert_equal  points.get_point([7,10]), :empty
    assert_equal  points.get_point([11,11]), :empty
    assert_equal  points.get_point([6,3]), :empty
  end

  def test_find_all_points
    game = Game.new
    board = game.board
    points = board.points

    assert_equal points.find_all_points(:empty).size, 91

    board.set_point([4,4], :red)
    board.set_point([9,9], :red)
    board.set_point([4,6], :white)
    board.set_point([2,3], :white)
    board.set_point([5,7], :white)
    board.set_point([5,9], :blue)
    board.set_point([8,9], :blue)
    board.set_point([5,3], :blue)
    board.set_point([10,8], :blue)
    assert_equal points.find_all_points(:red).size, 2
    assert_equal points.find_all_points(:white).size, 3
    assert_equal points.find_all_points(:blue).size, 4
    assert_equal points.find_all_points(:empty).size, 82
  end

  def test_adjacent_points
    game = Game.new
    analyzer = game.analyzer
    board = game.board

    assert analyzer.adjacent?([5,8],[5,7])
    assert analyzer.adjacent?([5,8],[4,7])
    assert analyzer.adjacent?([5,8],[4,8])
    assert analyzer.adjacent?([5,8],[5,9])
    assert analyzer.adjacent?([5,8],[6,9])
    assert analyzer.adjacent?([5,8],[6,8])
    assert analyzer.adjacent?([1,2],[1,3])
    assert analyzer.adjacent?([9,11],[8,10])
    assert analyzer.adjacent?([9,4],[10,5])
    assert analyzer.adjacent?([5,3],[6,3])
    assert analyzer.adjacent?([10,8],[11,9])
    assert_equal(analyzer.adjacent?([10,8,2],[11,9]), false)
    assert_equal(analyzer.adjacent?([3,1],[3,0]), false)
    assert_equal(analyzer.adjacent?([6,7],[4.5,3]), false)
    assert_equal(analyzer.adjacent?([:blue],[6,8]), false)
    assert_equal(analyzer.adjacent?([1,1],["2,1"]), false)
    assert_equal(analyzer.adjacent?([8,4],[8,4]), false)
    assert_equal(analyzer.adjacent?([5,8],[5,3]), false)
    assert_equal(analyzer.adjacent?([5,8],[11,9]), false)
    assert_equal(analyzer.adjacent?([5,8],[1,2]), false)
    assert_equal(analyzer.adjacent?([2,6],[9,9]), false)
    assert_equal(analyzer.adjacent?([7,10],[3,8]), false)
  end

  def test_all_adjacent_points
    game = Game.new
    analyzer = game.analyzer
    board = game.board

    assert_equal analyzer.all_adjacent_points([6,6]), [ [6,5], [7,6], [7,7], [6,7], [5,6], [5,5] ]
    assert_equal analyzer.all_adjacent_points([2,3]), [ [2,2], [3,3], [3,4], [2,4], [1,3], [1,2] ]
    assert_equal analyzer.all_adjacent_points([5,4]), [ [5,3], [6,4], [6,5], [5,5], [4,4], [4,3] ]
    assert_equal analyzer.all_adjacent_points([8,5]), [ [8,4], [9,5], [9,6], [8,6], [7,5], [7,4] ]
    assert_equal analyzer.all_adjacent_points([7,8]), [ [7,7], [8,8], [8,9], [7,9], [6,8], [6,7] ]
    assert_equal analyzer.all_adjacent_points([3,7]), [ [3,6], [4,7], [4,8], [3,8], [2,7], [2,6] ]
    assert_equal analyzer.all_adjacent_points([1,1]), [ [2,1], [2,2], [1,2] ]
    assert_equal analyzer.all_adjacent_points([4,1]), [ [5,1], [5,2], [4,2], [3,1] ]
    assert_equal analyzer.all_adjacent_points([6,1]), [ [7,2], [6,2], [5,1] ]
    assert_equal analyzer.all_adjacent_points([9,4]), [ [10,5], [9,5], [8,4], [8,3] ]
    assert_equal analyzer.all_adjacent_points([11,6]), [ [11,7], [10,6], [10,5] ]
    assert_equal analyzer.all_adjacent_points([11,8]), [ [11,7], [11,9], [10,8], [10,7] ]
    assert_equal analyzer.all_adjacent_points([11,11]), [ [11,10], [10,11], [10,10] ]
    assert_equal analyzer.all_adjacent_points([9,11]), [ [9,10], [10,11], [8,11], [8,10] ]
    assert_equal analyzer.all_adjacent_points([6,11]), [ [6,10], [7,11], [5,10] ]
    assert_equal analyzer.all_adjacent_points([2,7]), [ [2,6], [3,7], [3,8], [1,6] ]
    assert_equal analyzer.all_adjacent_points([1,6]), [ [1,5], [2,6], [2,7] ]
    assert_equal analyzer.all_adjacent_points([1,4]), [ [1,3], [2,4], [2,5], [1,5] ]
    assert_equal analyzer.all_adjacent_points([7,18]), []
    assert_equal analyzer.all_adjacent_points([4,0]), []
    assert_equal analyzer.all_adjacent_points([3,2,7]), []
    assert_equal analyzer.all_adjacent_points([57,11]), []
  end


  # Tests Part Two - Game Analysis Methods

  def test_get_all_groups
    game = Game.new
    board = game.board

    board.set_point([3,4], :red)
    board.set_point([4,6], :red)
    board.set_point([4,7], :red)
    board.set_point([4,5], :red)
    board.set_point([2,4], :red)
    board.set_point([3,7], :red)
    board.set_point([5,7], :red)
    board.set_point([7,4], :white)
    board.set_point([8,5], :white)
    board.set_point([5,3], :blue)
    board.set_point([3,3], :white)
    board.set_point([2,3], :white)
    board.set_point([3,2], :white)
    board.set_point([3,5], :blue)
    board.set_point([3,6], :blue)
    board.set_point([10,8], :white)
    board.set_point([10,7], :white)
    board.set_point([7,8], :blue)
    board.set_point([9,9], :blue)
    board.set_point([7,9], :blue)
    board.set_point([8,8], :blue)


    groups = game.analyzer.get_all_groups()
    assert_equal groups.class, Hash

    red = groups[:red]
    white = groups[:white]
    blue = groups[:blue]
    assert_equal red.class, Array
    assert_equal white.class, Array
    assert_equal blue.class, Array
  end


end


