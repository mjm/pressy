class Pressy::Console
  attr_reader :input, :output, :error

  def initialize(input: $stdin, output: $stdout, error: $stderr)
    @input = input
    @output = output
    @error = error
  end

  def prompt(label)
    error.print "#{label} "
    input.gets.chomp
  end
end
