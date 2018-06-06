require 'io/console'

class Pressy::Console
  attr_reader :input, :output, :error

  def initialize(input: $stdin, output: $stdout, error: $stderr)
    @input = input
    @output = output
    @error = error
  end

  def prompt(label, echo: true)
    error.print "#{label} "
    value = echo ? input.gets : input.noecho(&:gets)
    value.chomp
  end

  def run(*cmd)
    system(*cmd)
    $?
  end
end
