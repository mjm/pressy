require 'spec_helper'

RSpec.describe Pressy::Console do
  subject { Pressy::Console.new }

  it "provides direct access to standard input" do
    expect(subject.input).to be $stdin
  end

  it "provides direct access to standard output" do
    expect(subject.output).to be $stdout
  end

  it "provides direct access to standard error" do
    expect(subject.error).to be $stderr
  end

  describe "prompting for input" do
    it "prompts for a line of input" do
      expect($stderr).to receive(:print).with("What's your name? ")
      expect($stdin).to receive(:gets) { "None of your business\n" }

      name = subject.prompt("What's your name?")
      expect(name).to eq "None of your business"
    end

    let(:noecho) { double(:noecho) }

    it "prompts for input with echoing disabled" do
      expect($stderr).to receive(:print).with("What's your name? ")
      expect($stdin).to receive(:noecho).and_yield(noecho)
      expect(noecho).to receive(:gets) { "None of your business\n" }

      name = subject.prompt("What's your name?", echo: false)
      expect(name).to eq "None of your business"
    end
  end

  describe "running shell commands" do
    it "runs the shell command and returns the process status" do
      status = subject.run("exit 16")
      expect(status.exitstatus).to be 16
      expect(status).to be_exited
    end
  end
end
