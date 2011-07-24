require 'rubygems'
require 'gosu'

class Player_pic
  WIDTH = 8 * 3
  HEIGHT = 8 * 4
  OFFSET = 3
  
  def initialize(window)
    @window = window
    @i = 0
    @x_offset = (Map_pic::WIDTH  - WIDTH) / 2
    @y_offset = Map_pic::HEIGHT - HEIGHT - 7
  end

  def load_pic(file)
    @image = Gosu::Image.load_tiles(@window, file, WIDTH, HEIGHT, true)
  end
  
  def load_player_data(data)
    @player_data = data
  end
  
  def draw
    x, y = @player_data.pos
    # p x, y, @player_data.direction,  @player_data::Direction
    base = Player_data::Direction[@player_data.direction]
    base = base * OFFSET
    @i += 1
    @i %= OFFSET
    @image[base + @i].draw(Map_pic::WIDTH * x + @x_offset, Map_pic::HEIGHT * y + @y_offset, 0)
  end
end

class Player_data
  attr_accessor :id, :pos, :direction, :name, :items, :life, :flag, :map_data
  # attr_reader   :Direction

  Direction = {
    'U' => 0,
    'B' => 1,
    'L' => 2,
    'R' => 3
  }

  def initialize(map_data)
    @id  = nil
    @pos = [0,0]
    @direction = 'B'
    @name
    @items = []
    @life = 100
    @flag = []
    @map_data = map_data
  end
  
  def move(direction)
    @direction = direction
    dx, dy = @pos
    case direction
    when 'U'
      dy -= 1
      @pos = [dx, dy] if @map_data.is_accessible?(dx, dy)
    when 'B'
      dy += 1
      @pos = [dx, dy] if @map_data.is_accessible?(dx, dy)
    when 'L'
      dx -= 1
      @pos = [dx, dy] if @map_data.is_accessible?(dx, dy)
    when 'R'
      dx += 1
      @pos = [dx, dy] if @map_data.is_accessible?(dx, dy)
    else
    end
  end
  
  def set_pos
    xy = @map_data.player_pos.pop
    @pos = xy if not xy.nil?
  end
end

class Map_pic
  WIDTH = HEIGHT = 16 * 3
  def initialize(window)
    @window = window
  end

  def load_pic(file)
    @image = Gosu::Image.load_tiles(@window, file, WIDTH, HEIGHT, true)
  end
  
  def load_map_data(data)
    @map_data = data
  end
  
  def draw
    x = y = 0
    @map_data.map_d.map do |h|
      h.map do |w|
        @image[w].draw(x, y, 0)
        x += WIDTH
      end
      x = 0
      y += HEIGHT
    end
  end
end

class Map_data
  attr_reader :MapData, :map_d, :player_pos, :height, :width

  TREE = '#'
  ROAD = '+'
  ITEM = '*'
  PLAYER = '@'
  SPACE  = ' '

  MapData = {
    'RD_U'   => 1,
    'RD_UB'  => 2,
    'RD_UBLR'=> 3,
    'RD_B'   => 4,
    'RD_L'   => 5,
    'RD_LR'  => 6,
    'RD_R'   => 7,
    'RD_UR'  => 8,
    'RD_UL'  => 9,
    'RD_BL'  => 10,
    'RD_BR'  => 11,
    'RD_UBL' => 12,
    'RD_ULR' => 13,
    'RD_UBR' => 14,
    'RD_BLR' => 15,
    'RD_'    => 16,
  
    'ID'     => 21,

    'PL'     => 30, # Pass Line
    'TD'     => 31,
    'ND'     => 99
  }
  
  def initialize
    @map_o = @map_d = []
  end
  
  def load(file)
    begin
      open(file, "r") do |f|
        @map_o = f.readlines.map do |line| line.chomp end
      end
    rescue => e
      puts 'Map file loading error', e
      exit 1
    end
    
    # Create Map data
    @height = @map_o.size
    @width  = @map_o[0].size
    @map_d  = Array.new(@height) do |y|
      Array.new(@width) do |x|
        case @map_o[y][x]
        when TREE
          MapData['TD']
        when PLAYER
          add_player_pos(x, y)
          check_road(x, y)
        when ROAD
          check_road(x, y)
        when ITEM
          MapData['ID']
        else
          MapData['ND']
        end
      end
    end

    @map_o
  end

  def add_player_pos(x, y)
    @player_pos ||= []
    @player_pos.push([x, y])
  end
  
  def check_road(x, y)
    q = 'RD_'
    
    # Check upper
    dx = x
    dy = y - 1
    n = @map_o[dy][dx]
    unless n == SPACE or n == TREE
      q << 'U'
    end 
    
    # Check bottom
    dx = x
    dy = y + 1
    n = @map_o[dy][dx]
    unless n == SPACE or n == TREE
      q << 'B'
    end
    
    # Check left
    dx = x - 1
    dy = y
    n = @map_o[dy][dx]
    unless n == SPACE or n == TREE
      q << 'L'
    end
    
    # Check right
    dx = x + 1
    dy = y
    n = @map_o[dy][dx]
    unless n == SPACE or n == TREE
      q << 'R'
    end

    MapData[q]
  end
  
  def is_accessible?(x, y)
    MapData['PL'] > @map_d[y][x]
  end
end

class GameWindow < Gosu::Window
  VERSION = 0.01

  def initialize
    super(1024, 480, false)
    self.caption = "Gosuroku #{VERSION}"

    @map_data = Map_data.new
    p @map_data.load(File.join( File.dirname(__FILE__), '..', 'map_data', 'map02.txt'))
    @map_pic  = Map_pic.new(self)
    @map_pic.load_pic(File.join( File.dirname(__FILE__), '..', 'pic', 'map', 'map_set.bmp'))
    @map_pic.load_map_data(@map_data)
    @player_data = Player_data.new(@map_data)
    @player_data.set_pos
    @player_pic = Player_pic.new(self)
    @player_pic.load_pic(File.join( File.dirname(__FILE__), '..', 'pic', 'player', 'player_set.bmp'))
    @player_pic.load_player_data(@player_data)
    p @map_data.map_d
    p @map_data.player_pos
  end

  def update
  end

  def draw
    @map_pic.draw
    @player_pic.draw
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end
window = GameWindow.new
window.show