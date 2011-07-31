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
