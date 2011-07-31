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
    base = Player_data::Direction[@player_data.direction]
    base = base * OFFSET
    i = Gosu::milliseconds / 200 % OFFSET
    @image[base + i].draw(Map_pic::WIDTH * x + @x_offset, Map_pic::HEIGHT * y + @y_offset, 0)
  end
end

class Player_data
  attr_accessor :id, :pos, :direction, :name, :items, :life, :flag, :map_data

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
    @life = 100
    @flag = []
    @map_data = map_data
  end
  
  def move(direction)
    @direction = direction
    dx, dy = @pos
    case direction
    when :U
      dy -= 1
      @pos = [dx, dy] if @map_data.is_accessible?(dx, dy)
    when :B
      dy += 1
      @pos = [dx, dy] if @map_data.is_accessible?(dx, dy)
    when :L
      dx -= 1
      @pos = [dx, dy] if @map_data.is_accessible?(dx, dy)
    when :R
      dx += 1
      @pos = [dx, dy] if @map_data.is_accessible?(dx, dy)
    else
      nil
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

class Event
  def initialize
    @id = nil
    @type = nil

    open_attr
  end

  def open_attr
    self.instance_variables.map do |var|
      self.class.send(:attr_accessor, var.to_s.delete('@'))
    end
  end

  def reset
    self.instance_variables.map do |var|
      self.instance_variable_set(var, nil)
    end
  end

  def create_dice_event(player, value)
    @id = player.id
    @type = :dice
    @value = value
    open_attr
    self
  end

  def create_player_move(player, direction, remain)
    @id = player.id
    @type = :p_move
    @direction = direction
    @remain = remain
    open_attr
    self
  end
end

class Event_manager
  # attr_reader :q
  DummyEVT = Event.new
  
  def initialize
    @q = []
  end
  
  def pop
    evt = @q.pop
    if evt.nil?
      evt = DummyEVT
    end
    return evt
  end
  
  def push(evt)
    @q.push(evt)
  end
end

class GameWindow < Gosu::Window
  VERSION = 0.01

  def initialize
    super(1024, 480, false)
    self.caption = "Gosuroku #{VERSION}"

    @map_data = Map_data.new
    @map_data.load(File.join( File.dirname(__FILE__), '..', 'map_data', 'map02.txt'))
    @map_pic  = Map_pic.new(self)
    @map_pic.load_pic(File.join( File.dirname(__FILE__), '..', 'pic', 'map', 'map_set.bmp'))
    @map_pic.load_map_data(@map_data)
    @player_data = Player_data.new(@map_data)
    @player_data.set_pos
    @player = Hash.new
    @player_data.id = 'aboutwxruby'.to_sym
    @player[@player_data.id] = @player_data
    @player_pic = Player_pic.new(self)
    @player_pic.load_pic(File.join( File.dirname(__FILE__), '..', 'pic', 'player', 'player_set.bmp'))
    @player_pic.load_player_data(@player_data)
    @map_data.map_d
    @map_data.player_pos
    
    @evt_mng = Event_manager.new
    @evt_mng.push(Event.new.create_dice_event(@player_data, 6))
    p @evt_mng
  end

  def update
    evt = @evt_mng.pop 
    p 'evt', evt
      case evt.type
      when :p_move
        player = @player[evt.id]
        ret = player.move(evt.direction)
        unless ret.nil?
          remain = evt.remain - 1
        else
          remain = evt.remain
        end
        @evt_mng.push(Event.new.create_dice_event(@player_data, remain)) if remain > 0
      when :dice
        if button_down? Gosu::KbUp or button_down? Gosu::GpUp
          @evt_mng.push(Event.new.create_player_move(@player_data, :U, evt.value))
        elsif button_down? Gosu::KbDown or button_down? Gosu::GpDown
          @evt_mng.push(Event.new.create_player_move(@player_data, :B, evt.value))
        elsif button_down? Gosu::KbLeft or button_down? Gosu::GpLeft
          @evt_mng.push(Event.new.create_player_move(@player_data, :L, evt.value))
        elsif button_down? Gosu::KbRight or button_down? Gosu::GpRight
          @evt_mng.push(Event.new.create_player_move(@player_data, :R, evt.value))
        else
          @evt_mng.push(evt)
        end
      else
      end # unless evt.nil?
    # end
    # twitter
    # thd = Thread.start do
      # while (evt = evt_mng.q.pop )
      # end
    # end
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