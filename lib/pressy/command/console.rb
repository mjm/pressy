require 'pry'

class Pressy::Command::Console
  def self.name
    :console
  end

  def initialize(site, _console)
    @site = site
  end

  def run
    site = @site
    raise "no site found" unless site # mostly to stop warnings of site being unused
    Pry.start(binding, quiet: true, prompt: Pry::SIMPLE_PROMPT)
  end
end
