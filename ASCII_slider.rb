class MoveThumbException < StandardError
end

class Slider
  attr_accessor :position, :size, :skin

  def initialize(size = 16)
    @size = size
    @position = size/2
  end

  def magnitude_to_absolute_position(magnitude)
    if magnitude == 1.0
      deflection = @size/2
    else
      deflection = ( (@size/2) * magnitude).to_i
    end
    return deflection + (@size/2).to_i
  end

  def shift_thumb(magnitude)
    if magnitude.class == Fixnum
      if magnitude <= 10 && magnitude >= -10
        @position = magnitude_to_absolute_position(magnitude/10.0) 
      else
        raise MoveThumbException
      end
    elsif magnitude.class == Float
      if magnitude <= 1.0 && magnitude >= -1.0
        @position = magnitude_to_absolute_position(magnitude)
      else
        raise MoveThumbException
      end
    end
  end
end

class SliderController

  def initialize
    @slider = Slider.new
    @view = SliderView.new
  end

  def shift_slider(magnitude)
    begin
      @slider.shift_thumb(magnitude)
    rescue MoveThumbException
      puts "Error: please enter an integer between -10 and 10 or a float between -1 and 1"
    end
    @view.draw_slider(@slider)
  end

  def move_slider(relative_position)
    if relative_position == 0
      @slider.position = @slider.size/2
    else
      @slider.position += relative_position
    end
    @view.draw_slider(@slider)
  end

  def dispatch(args)
    if ARGV[0] =~ /^-*i/
      parse_input( {interactive: true} )
    elsif ARGV[0] =~ /^-*h/
      help = <<-ENDEND
      usage: ruby ASCII_slider.rb [-i|--interactive]
      ENDEND
      puts help
    else
      parse_input
    end
  end

  def parse_input(options = {})
    @view.prompt_skin
    @view.draw_slider(@slider)
    if options[:interactive]
      puts "Enter 'q' to exit. 's' to change the track character, or 'c' to toggle screen clearing mode"
      while true
        input = @view.prompt_move
        if input[:quit]
          puts "Exiting"
          break
        elsif input[:reskin]
          @view.prompt_skin
          @view.draw_slider(@slider)
        elsif input[:clear_screen]
          @view.screen_clearing_mode = !@view.screen_clearing_mode
        elsif input[:command]
          move_slider( input[:command] )
        else
          shift_slider(input[:magnitude])
        end
      end
    else
      input = @view.prompt_move
      if input[:quit]
        puts "Exiting"
      elsif input[:command]
        move_slider( input[:command] )
      else
        shift_slider(input[:magnitude])
      end
    end
  end

end

class SliderView
  attr_accessor :screen_clearing_mode

  def initialize
    @skin = "="
    @screen_clearing_mode = false
  end

  def prompt_skin()
    puts "What would you like the slider to look like?"
    input = $stdin.gets.chomp
    @skin = input[0] unless input == ""
  end

  def prompt_move
    puts "Enter a position"
    input = $stdin.gets.chomp
    return { quit: true } if input =~ /^q/
    case input
    when "0"
      return { magnitude: input.to_i }
    when "0.0", "1.0", "-1.0"
      return { magnitude: input.to_f }
    when "<"
      return { command: -1 }
    when ">"
      return { command: 1 }
    when "|"
      return { command: 0 }
    when "s"
      return { reskin: true }
    when "c"
      return { clear_screen: true}
    end
    input = input.to_f
    if input % 1 == 0
      { magnitude: input.to_i }
    else
      { magnitude: input }
    end
  end

  def draw_slider(slider)
    if @screen_clearing_mode
      system "clear"
      system ("cls")
    end
    graphic = []
    slider.size.times { graphic.push(@skin) }
    graphic.insert( slider.position, "[]" )
    graphic.each do |e| 
      print e
    end
    puts ""
  end
end

c = SliderController.new
c.dispatch(ARGV)
