class Pressy::Command::Runner
  def initialize(registry, site, console, env)
    @registry = registry
    @site = site
    @console = console
    @env = env
  end

  def run(action, *args)
    raise "no action given" unless action

    command_type = @registry.lookup(action) or raise "unexpected action '#{action.to_s}'"
    options = command_type.parse!(args)
    command_type.new(@site, @console, @env).run(options, *args)
  end
end
