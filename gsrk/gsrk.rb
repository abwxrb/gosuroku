require 'rubygems'
require 'gosu'
dir = File.dirname(__FILE__)
require File.join( dir,'gsrk_pic.rb')
require File.join( dir,'gsrk_data.rb')
require File.join( dir,'gsrk_event.rb')

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