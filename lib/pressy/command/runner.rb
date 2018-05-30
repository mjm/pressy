class Pressy::Command::Runner
  def initialize(site, stderr)
    @site = site
    @stderr = stderr
    @commands = {}
  end

  def register(type)
    @commands[type.name] = type
  end

  def run(action, *args)
    raise "no action given" unless action

    command_type = @commands[action] or raise "unexpected action '#{action.to_s}'"
    command_type.new(@site, @stderr).run(*args)
  end
end
