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
    case @player_data.status
    when :NOTHING
      draw_nothing
    when :MOVE
      draw_move
    else
      nil
    end
  end
  
  def draw_move
    x, y = @player_data.pos
    dx = dy = 0
    case @player_data.direction
    when :U
      dy = -1
    when :B
      dy = 1
    when :L
      dx = -1
    when :R
      dx = 1
    end
    @ax ||= Map_pic::WIDTH * - dx
    @ay ||= Map_pic::HEIGHT * - dy
    mx = Map_pic::WIDTH * x + @x_offset + @ax
    my = Map_pic::HEIGHT * y + @y_offset + @ay
    draw_player(mx, my)
    @ax += dx
    @ay += dy
    if @ax == 0 and @ay == 0
      @ax = @ay = nil
      @player_data.status = :NOTHING
    end
  end

  def draw_nothing
    x, y = @player_data.pos
    x = Map_pic::WIDTH * x + @x_offset
    y = Map_pic::HEIGHT * y + @y_offset
    draw_player(x, y)
  end
  
  def draw_player(x, y)
    base = Player_data::Direction[@player_data.direction]
    base = base * OFFSET
    i = Gosu::milliseconds / 200 % OFFSET
    @image[base + i].draw(x, y, 0)
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
