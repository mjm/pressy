require 'spec_helper'

RSpec.describe Pressy::Command::Console do
  include_examples "command", :console

  it "starts Pry with the site defined locally" do
    expect(Pry).to receive(:start).with(instance_of(Binding), {quiet: true, prompt: Pry::SIMPLE_PROMPT}) do |bind|
      expect(bind.local_variable_get(:site)).to be site
    end

    subject.run
  end
end
