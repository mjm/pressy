require 'spec_helper'

RSpec.describe Pressy::Command::Runner do
  let(:site) { double(:site) }
  let(:console) { double(:console) }
  let(:env) { {"A" => "B", "C" => "D"} }
  let(:registry) { instance_double("Pressy::Command::Registry") }
  subject { Pressy::Command::Runner.new(registry, site, console, env) }

  describe "running commands" do
    let(:command_type) { double(:command_type) }
    let(:command) { double(:command) }

    context "when no command is provided" do
      it "raises an error" do
        expect { subject.run(nil) }.to raise_error("no action given")
      end
    end

    context "when the command is registered" do
      before do
        expect(registry).to receive(:lookup).with(:pull) { command_type }
        expect(command_type).to receive(:new).with(site, console, env) { command }
      end

      it "runs the matching command" do
        expect(command).to receive(:run)
        subject.run(:pull)
      end

      it "passes arguments down to the command" do
        expect(command).to receive(:run).with("a", "b")
        subject.run(:pull, "a", "b")
      end
    end

    context "when the command is not registered" do
      before do
        expect(registry).to receive(:lookup).with(:pull) { nil }
      end

      it "raises an error" do
        expect { subject.run(:pull) }.to raise_error("unexpected action 'pull'")
      end
    end
  end
end
