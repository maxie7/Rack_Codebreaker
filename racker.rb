require 'erb'
require 'bundler/setup'
require 'codebreaker'
class Racker
  def call(env)
    @request = Rack::Request.new(env)
    start false
    case @request.path
      when "/"
        start true
        start_game
        render_index
      when "/hint"
        hint
      when "/check"
        check
      when "/get_code"
        get_code
      when "/get_move"
        get_move
      when "/add_data"
        @save_score = Codebreaker::Player.new
        load_data
        add_data
        save_score
      else
        Rack::Response.new("Not Found",404)
    end
  end

  def start_game
    Rack::Response.new(@game.start)
  end

  def render_index
    Rack::Response.new(render("index.html.erb"))
  end

  def hint
    Rack::Response.new(@game.hint)
  end

  def check
    response = @game.guess_check @request.params['val']
    Rack::Response.new(response)
  end

  def get_code
    Rack::Response.new(@game.secret_code)
  end

  def get_move
    Rack::Response.new("#{@game.move_number}")
  end

  def load_data
    Rack::Response.new(@save_score.load_info)
  end

  def add_data
    response  = @save_score.add(Codebreaker::User.new(name: @request.params['val'], moves: @game.move_number))
    Rack::Response.new(response)
  end

  def save_score
    Rack::Response.new(@save_score.save_info)
  end

  def render(template)
    path = File.expand_path("public/views/#{template}")
    ERB.new(File.read(path)).result(binding)
  end

  def start(b)
    return @game = Codebreaker::Game.new  if b
    @game ||= Codebreaker::Game.new
  end
end
