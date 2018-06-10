require "bundler/setup"
require "pressy"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec.shared_examples "command" do |name|
  let(:stderr) { StringIO.new }
  let(:console) { instance_double("Pressy::Console", error: stderr) }
  let(:env) { {} }
  let(:site) { instance_double("Pressy::Site") }

  subject { described_class.new(site, console, env) }

  it "has command name '#{name}'" do
    expect(described_class.name).to be name
  end

  it "is registered in the default command registry" do
    registry = Pressy::Command::Registry.default
    expect(registry.lookup(name)).to be described_class
  end

  it "parses an empty list of arguments" do
    args = []
    expect(described_class.parse!(args)).to eq({})
    expect(args).to be_empty
  end
end
