require 'pry'

Pressy::Command.define :console do
  def run
    site = self.site
    raise "no site found" unless site # mostly to stop warnings of site being unused
    Pry.start(binding, quiet: true, prompt: Pry::SIMPLE_PROMPT)
  end
end
