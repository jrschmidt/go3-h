require 'rubygems'

require 'sinatra'

require 'coffee-script'

require 'pry'



class Game

  attr :board, :analyzer, :legal_moves, :manager


  def initialize
    @board = Board.new
    @analyzer = GroupAnalyzer.new(self)
    @legal_moves = LegalMovesFinder.new(self)
    @manager = GameplayManager.new(self)
  end


  def start
    @manager.start
  end


end



class GameplayManager

  COLORS = [:red, :white, :blue]

  def initialize(game_object)
    @game = game_object
    @board = @game.board
    @points = @board.points
    @analyzer = @game.analyzer

    @players = {}
    @players[:red] = HumanPlayer.new(@game, :red)
    @players[:white] = AiPlayer.new(@game, :white)
    @players[:blue] = AiPlayer.new(@game, :blue)

    @current_player = :red
  end


  # ("Console Play" Version)
  def start
    stop = false
    until stop do
      point = get_next_move(@current_player)
      make_a_move(@current_player,point)
      next_player
    end
  end


  def get_next_move(player)
    move = @players[player].get_move
    return move
  end


  def make_a_move(player,point)
    @points.set_point(point,player)
    puts "Player #{player} makes a move at #{point}"

    remove_dead_stones_after_move(player)
  end


  def remove_dead_stones_after_move(player)
    opponents = [:red, :white, :blue]
    opponents.delete(player)
    opponents.each do |opp|
      dead_groups = @analyzer.dead_groups?(opp)
      dead_groups.each do |grp|
        @points.set_points(:empty, grp)
      end
    end
  end


  def whose_turn?
    return @current_player
  end


  def next_player
    case @current_player
    when :red
      @current_player = :white
    when :white
      @current_player = :blue
    when :blue
      @current_player = :red
    end
  end


end



class Player

  attr :color

  def initialize(game,color)
    @game = game
    @legal_moves = @game.legal_moves

    @color = color
  end

end



class HumanPlayer < Player

  # (CONSOLE Play Version)
  def get_move
    str = gets
    return string_to_point(str)
  end


  def string_to_point(string)
    point = []
    pt = string.split(",")
    point[0] = pt[0].to_i
    point[1] = pt[1].to_i
    return point
  end

end



class AiPlayer < Player

  # AI VERSION:  0.01

  # Random selection from set of legal playable points. No additional heuristic.

  def get_move
    open = @legal_moves.find_legal_moves(@color)
    move = open.sample
    return move
  end


end



class Board
    # This class models the layout of the gameboard.
    # (The positions of stones on the board are represented by an instance of
    # the GameBoardPoints class.)

  include Enumerable

  attr :points

  ROW_START = [nil,1,1,1,1,1,1,2,3,4,5,6]
  ROW_END = [nil,6,7,8,9,10,11,11,11,11,11,11]
  MIN = 1
  MAX = 11

  def initialize
    @points = GameBoardPoints.new()
  end


  def each
    1.upto(MAX) do |i|
      ROW_START[i].upto(ROW_END[i]) do |j|
        pt = [i,j]
        yield pt
      end
    end
  end


  def valid_point?(point)
    valid = false

    if point.class == Array && point.size == 2 && point.count {|p| p.class == Fixnum} == 2
      a = point[0]
      b = point[1]
      if a>=MIN && a<= MAX
        valid = true if b >= ROW_START[a] && b <= ROW_END[a]
      end
    end

    return valid
  end


  def adjacent?(pt1,pt2)
    adj = true
    adj = false if pt1.class != Array || pt2.class != Array
    adj = false if pt1.size != 2 || pt2.size != 2
    adj = false if [pt1,pt2].flatten.count {|z| z.class == Fixnum} != 4
    adj = false if valid_point?(pt1) == false || valid_point?(pt2) == false

    if adj == true
      a1 = pt1[0]
      b1 = pt1[1]
      a2 = pt2[0]
      b2 = pt2[1]
      adj = false if (a1-a2).abs > 1 || (b1-b2).abs > 1
      adj = false if (a1 == a2) && (b1 == b2)
      adj = false if (a1 == a2+1) && (b1 == b2-1)
      adj = false if (a1 == a2-1) && (b1 == b2+1)
    end

    return adj
  end

  def all_adjacent_points(p)
    # Returns an array containing the set of adjacent valid points in
    # clockwise order as follows: :right_up, :right, :right_dn, :left_dn,
    # :left, :left_up

    filter = [ [0,-1], [1,0], [1,1], [0,1], [-1,0], [-1,-1] ]
    return get_adjacent_points(p,filter)
  end


  def all_previous_adjacent_points(p)
    # Returns an array containing the set of adjacent valid points which
    # are returned before the point p by the each method, in this order:
    # :left_up, :right_up, :left

    filter = [ [-1,-1], [0,-1], [-1,0] ]
    return get_adjacent_points(p,filter)
  end


  def get_adjacent_points(p,filter)

    points = []
    if valid_point?(p)
      a = p[0]
      b = p[1]
      for delta in filter
        z = [ (a + delta[0]), (b + delta[1]) ]
        points << z if valid_point?(z)
      end
    end
    return points
  end


end



class GameBoardPoints
  # A collection of values for each point on the game board

  include Enumerable


  def initialize
    @point_values = []
  end


  def get_point(point)
    result = @point_values.find {|pt| pt[:point] == point }
    if result == nil
      val = :empty
    else
      val = result[:value]
    end
    return val
  end


  def set_point(point,value)
    if value == :empty
      @point_values.delete_if {|pt| pt[:point] == point }
    else
      zz = @point_values.find {|pt| pt[:point] == point }
      if zz != nil
        zz[:value] = value
      else
        @point_values << {point: point, value: value}
      end
    end
  end


  def set_points(value, points_array)
    points_array.each {|pt| set_point(pt,value)}
  end

end



class LegalMovesFinder
    # A class to find the set of all legal moves for a player

  def initialize(game_object)
    @game = game_object
    @board = @game.board
    @points = @board.points
    @analyzer = @game.analyzer
    @group_points = @analyzer.group_points
  end


  def find_legal_moves(player_color)
    not_legal = []

    groups = @analyzer.find_all_groups
    eyes = @analyzer.find_empty_points_for_groups(groups)

    # TODO Let's refactor this part to find all 'one-eyes' for all colors.
    # Then we can use one_eyes[:color] like we do here, and one_eyes[:other_color_1]
    # and one_eyes[:other_color_2] to find the 'isolated one-eyes'.


    [:red, :white, :blue].each do |color|
      g1 = eyes.find_all {|gp| gp[:color] == color && gp[:eyes].size == 1 }
      one_eyes = []
      g1.each do |gp|
        nbrs = @board.all_adjacent_points(gp[:eyes][0])
        one_eyes << gp unless nbrs.find {|pt| @points.get_point(pt) == :empty }
      end
    end

    one_eyes[player_color].each do |gp|
      pt = gp[:eyes][0]
      g_share = eyes.find_all {|gpx| gpx[:eyes].include?(pt) }
      if g_share.find {|gpz| gpz[:color] == player_color && gpz[:eyes].size > 1 }
        legal = true
      elsif g_share.find {|gpz| gpz[:color] != player_color && gpz[:eyes].size == 1 }
        legal = true
      else
        legal = false
      end
      not_legal << pt if legal == false
    end

    # TODO  -- FINDING 'ISOLATE' ONE-EYES --

    # FIXME HERE WE GO THROUGH THE ONE-EYE GROUPS FOR OTHER COLORS, AND ADD THEM TO
    # not_legal[] IF: There is no neighboring stone for player_color, AND
    #                 Each of the neighbor groups for the point have more than one eye.


    moves = @board.find_all {|point| @points.get_point(point) == :empty} - not_legal

    # FIXME We aren't doing this, we have a better idea (see ln:329 note)
    moves.each do |pt|
      ok = true
      nbrs = @board.all_adjacent_points(pt)
      if nbrs.find {|ptt| @points.get_point(ptt) == :empty } == nil &&
         nbrs.find {|ptc| @points.get_point(ptc) == color } == nil &&
         # TODO Each Neighbor Group Has More Than One Eye
    end

    return moves
  end

end



class GroupAnalyzer
    # Provides analysis of groups of stones

  attr :group_points

  def initialize(game_object)
    @game = game_object
    @board = @game.board
    @points = @board.points

    @group_points = GameBoardPoints.new()
  end


  def find_all_groups
    groups = {red: [], white: [], blue: []}

    @board.each do |point|
      if @points.get_point(point) != :empty
        color = @points.get_point(point)

        neighbor_groups = find_same_color_neighbor_groups(point,color)

        if neighbor_groups.size == 0
          group = make_new_group(groups, color)
          gid = group[:id]
        else
          gid = neighbor_groups[0][:id]
          group = {color: color, id: gid}
        end

        if neighbor_groups.size > 1
          old_id = neighbor_groups[1][:id]
          groups[color][gid].concat( groups[color][old_id] )
          groups[color][old_id] = nil
          neighbor_groups[1][:stones].each {|pt| @group_points.set_point(pt,group) }
        end

        groups[color][gid] << point
        @group_points.set_point(point,group)
      end
    end

    [:red, :white, :blue].each {|color| groups[color].compact! }
    return groups
  end


  def dead_groups?(color)
    dead_groups = []

    groups = find_all_groups
    own_groups = groups[color]

    own_groups.each do |grp|
      eyes = find_group_airpoints(grp)
      dead_groups << grp if eyes == []
    end

    return dead_groups
  end


  def find_same_color_neighbor_groups(point,color)
    neighbor_groups = []
    group_ids = []

    amigos = []
    for nb in @board.all_previous_adjacent_points(point)
      amigos << nb if @points.get_point(nb) == color
    end

    amigos.each do |pt|
      grp_id = @group_points.get_point(pt)[:id]
      group_ids << grp_id if not group_ids.include?(grp_id)
    end

    group_ids.each do |id|
      stones = get_group_stones(color, id)
      grp = {id: id, stones: stones}
      neighbor_groups << grp
    end

    return neighbor_groups
  end


  def get_group_stones(color, id)
    return @board.find_all {|point| @group_points.get_point(point) == {color: color, id: id} }
  end


  def find_empty_points_for_groups(groups)
    empty_points = []

    [:red, :white, :blue].each do |color|
      groups[color].each do |group|
        eyes = find_group_airpoints(group)
        empty_points << {color: color, eyes: eyes, points: group}
      end
    end

    return empty_points
  end


  def make_new_group(groups, color)
    i = groups[color].size
    groups[color][i] = []
    group = {color: color, id: i}
    return group
  end


  def find_group_airpoints(group)
    air = []
    for stone in group
      air << @board.all_adjacent_points(stone).select {|pt| @board.points.get_point(pt) == :empty}
    end
    air.flatten!(1).uniq!
    return air
  end

end



class PointStringBuilder
    # A class that encodes a set of points into a string

  HEX_D = {10 => "a",
           11 => "b",
           12 => "c",
           13 => "d",
           14 => "e",
           15 => "f" }

  def points_to_string(points)
    str = points.map {|pt| point_to_string(pt)}.join
    return str
  end


  def point_to_string(point)
    str = hex_digit(point[0]) + hex_digit(point[1])
    return str
  end


  def hex_digit(n)
    dd = n<10 ? n.to_s : HEX_D[n] if n >= 0 && n < 16
    dd = " " if n<0 || n>15
    return dd
  end

end



