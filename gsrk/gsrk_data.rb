class Player_data
  attr_accessor :id, :pos, :direction, :name, :items, :hp, :mp, :flag, :map_data, :status

  Direction = {
    :U => 0,
    :B => 1,
    :L => 2,
    :R => 3
  }

  def initialize(map_data)
    @id  = nil
    @pos = [0,0]
    @direction = :B
    @name
    @items = []
    @hp = 100
    @mp = 100
    @flag = []
    @map_data = map_data
    @status = :NOTHING
  end
  
  def move(direction)
    @direction = direction
    dx, dy = @pos
    case direction
    when :U
      dy -= 1
      if @map_data.is_accessible?(dx, dy)
        @pos = [dx, dy]
        @status = :MOVE
      end
    when :B
      dy += 1
      if @map_data.is_accessible?(dx, dy)
        @pos = [dx, dy]
        @status = :MOVE
      end
    when :L
      dx -= 1
      if @map_data.is_accessible?(dx, dy)
        @pos = [dx, dy]
        @status = :MOVE
      end
    when :R
      dx += 1
      if @map_data.is_accessible?(dx, dy)
        @pos = [dx, dy]
        @status = :MOVE
      end
    else
      nil
    end
  end
  
  def set_pos
    xy = @map_data.player_pos.pop
    @pos = xy if not xy.nil?
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
