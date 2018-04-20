require 'spec_helper'

RSpec.describe Pressy::Site do
  let(:config) do
      {
        "site" => {
          "host" => "example.com",
          "username" => "alex",
          "password" => "pressy",
        },
      }
  end
  let(:store) { instance_double("Pressy::Store::FileStore") }
  let(:wordpress) { instance_double("Wordpress") }

  before(:each) do
    allow(store).to receive(:configuration) { config }
    allow(Wordpress).to receive(:connect) { wordpress }
  end

  it "creates a new site with a configured Wordpress client" do
    expect(Wordpress).to receive(:connect).with(config) { wordpress }
    Pressy::Site.new(store)
  end
end
