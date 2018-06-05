class Pressy::Command::Runner
  def initialize(registry, site, console)
    @registry = registry
    @site = site
    @console = console
  end

  def run(action, *args)
    raise "no action given" unless action

    command_type = @registry.lookup(action) or raise "unexpected action '#{action.to_s}'"
    command_type.new(@site, @console).run(*args)
  end
end
