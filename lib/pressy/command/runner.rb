class Pressy::Command::Runner
  def initialize(site, console)
    @site = site
    @console = console
    @commands = {}
  end

  def register(type)
    @commands[type.name] = type
  end

  def run(action, *args)
    raise "no action given" unless action

    command_type = @commands[action] or raise "unexpected action '#{action.to_s}'"
    command_type.new(@site, @console).run(*args)
  end
end
