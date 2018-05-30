require 'spec_helper'

RSpec.describe Pressy::Command::Runner do
  let(:site) { double(:site) }
  let(:stderr) { double(:stderr) }
  subject { Pressy::Command::Runner.new(site, stderr) }

  describe "running commands" do
    context "when no command is provided" do
      it "raises an error" do
        expect { subject.run(nil) }.to raise_error("no action given")
      end
    end

    context "when there are no command registered" do
      it "raises an error when running any command" do
        expect { subject.run(:pull) }.to raise_error("unexpected action 'pull'")
      end
    end

    context "when the command is registered" do
      let(:pull) { make_command(:pull) }
      let(:push) { make_command(:push) }

      before do
        subject.register(pull)
        subject.register(push)
      end

      it "runs the matching command" do
        expect(pull.instance).to receive(:run)
        expect(push.instance).not_to receive(:run)
        subject.run(:pull)
      end

      it "passes arguments down to the command" do
        expect(pull.instance).to receive(:run).with("a", "b")
        subject.run(:pull, "a", "b")
      end
    end

    context "when the command is not registered" do
      before do
        subject.register(double(name: :push))
      end

      it "raises an error" do
        expect { subject.run(:pull) }.to raise_error("unexpected action 'pull'")
      end
    end
  end

  def make_command(name)
    instance = double(:"#{name}_instance")
    command = double(name: name, instance: instance)
    allow(command).to receive(:new).with(site, stderr) { instance }
    command
  end
end
