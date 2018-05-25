require 'spec_helper'

ConsoleCommand = Pressy::Command::Console

RSpec.describe ConsoleCommand do
  let(:stderr) { StringIO.new }
  let(:site) { double(:site) }
  subject { ConsoleCommand.new(site, stderr) }

  it "has command name 'console'" do
    expect(ConsoleCommand.name).to be :console
  end

  it "starts Pry with the site defined locally" do
    expect(Pry).to receive(:start).with(instance_of(Binding), {quiet: true, prompt: Pry::SIMPLE_PROMPT}) do |bind|
      expect(bind.local_variable_get(:site)).to be site
    end

    subject.run
  end
end
