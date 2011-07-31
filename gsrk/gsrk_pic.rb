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
