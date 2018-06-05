require 'spec_helper'

RSpec.describe Pressy::Command::Registry do
  Registry = Pressy::Command::Registry
  subject { Registry.new }

  let(:pull) { double(name: :pull) }

  before do
    subject.register(pull)
  end

  describe "looking up command types" do
    it "returns nil if no command type is registered for the name" do
      expect(subject.lookup(:push)).to be_nil
    end

    it "returns the type if one is registered for the name" do
      expect(subject.lookup(:pull)).to be pull
    end
  end

  describe "the default registry" do
    it "is a registry" do
      expect(Registry.default).to be_a Registry
    end

    it "is always the same registry" do
      expect(Registry.default).to be Registry.default
    end
  end
end
