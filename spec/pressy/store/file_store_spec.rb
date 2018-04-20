require 'spec_helper'

STORE_FIXTURES_PATH = File.expand_path File.join(File.dirname(__FILE__), '../../fixtures/store')

RSpec.describe Pressy::Store::FileStore do
  let(:empty_store) { store(:empty_store) }
  let(:example_store) { store(:example_store) }

  context "reading posts" do
    it "reads from an empty store" do
      expect(empty_store.all_posts).to be_empty
    end

    it "reads posts from a store with contents" do
      posts = example_store.all_posts.sort_by(&:path)
      expect(posts.count).to be 4
      expect(posts.map(&:path)).to eq [
        "standard/announcing-pressy.md",
        "standard/welcome-to-wordpress.md",
        "status/status-post-1.md",
        "status/status-post-2.md",
      ]
      expect(posts.map(&:digest)).to eq [
        "46944d16c3ffdfa9d03a09dba9b42d873bc66b30c14d8a4b200499071d633a99",
        "8d198fd679f2cc0631c10b72aabc54b41c73d9ebbcef2f8405707a83b317652e",
        "d3723b47c2a83e688c094f427a25bbe25166c608ec2e1a03f19b4ed8d7bcd4af",
        "296534ec795162c278e1b2a588cd68c192cef0a8a6d6fd5999cfd9bf7d5ffaf9"
      ]
    end
  end
end

def store(name)
  Pressy::Store::FileStore.new(store_path(name))
end

def store_path(name)
  File.join(STORE_FIXTURES_PATH, name.to_s)
end
