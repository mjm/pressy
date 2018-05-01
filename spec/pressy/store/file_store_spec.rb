require 'spec_helper'
require 'fileutils'
require 'tmpdir'

STORE_FIXTURES_PATH = File.expand_path File.join(File.dirname(__FILE__), '../../fixtures/store')

RSpec.describe Pressy::Store::FileStore do
  let(:tmpdir) { Dir.mktmpdir }
  let(:empty_store) { store(:empty_store) }
  let(:example_store) { store(:example_store) }

  after(:each) { FileUtils.rm_rf tmpdir }

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

  context "writing posts" do
    it "writes a post that doesn't yet exist" do
      digest = "593a3da32f58aa12f944c2e65d82aeae5282c47edb0e2fe01976039ed823a36b"
      post = Pressy::RenderedPost.new('standard/my-first-post.md', <<~CONTENT, digest)
      ---
      id: 1
      title: My First Post
      ---
      This is some post content.
      CONTENT
      empty_store.write(post)

      posts = empty_store.all_posts
      expect(posts).to eql [post]
    end

    it "overwrites a post that already exists" do
      digest = "7ae864ba1bfed200ffcd04ce452320ff8735d8c92414743ab9270f7a0a0d7149"
      post = Pressy::RenderedPost.new('standard/announcing-pressy.md', <<~CONTENT, digest)
      ---
      id: 4
      title: Announcing Pressy!
      status: publish
      ---
      Oh no I deleted all the stuff in this post.
      CONTENT
      example_store.write(post)

      posts = example_store.all_posts.sort_by(&:path)
      expect(posts.count).to be 4

      expect(posts.map(&:path)).to eq [
        "standard/announcing-pressy.md",
        "standard/welcome-to-wordpress.md",
        "status/status-post-1.md",
        "status/status-post-2.md",
      ]
      expect(posts.map(&:digest)).to eq [
        digest,
        "8d198fd679f2cc0631c10b72aabc54b41c73d9ebbcef2f8405707a83b317652e",
        "d3723b47c2a83e688c094f427a25bbe25166c608ec2e1a03f19b4ed8d7bcd4af",
        "296534ec795162c278e1b2a588cd68c192cef0a8a6d6fd5999cfd9bf7d5ffaf9"
      ]
    end
  end

  context "deleting posts" do
    it "deletes a post that exists" do
      post_to_delete = example_store.all_posts.first
      example_store.delete(post_to_delete)

      expect(example_store.all_posts.count).to be 3
    end
  end

  context "reading cached digests" do
    it "reads empty data if there is no digests file" do
      expect(empty_store.digests).to eq({})
    end

    it "reads the hashes from the digests YAML file" do
      expect(example_store.digests).to eq({
        4 => "46944d16c3ffdfa9d03a09dba9b42d873bc66b30c14d8a4b200499071d633a99",
        3 => "8d198fd679f2cc0631c10b72aabc54b41c73d9ebbcef2f8405707a83b317652e",
        1 => "d3723b47c2a83e688c094f427a25bbe25166c608ec2e1a03f19b4ed8d7bcd4af",
        2 => "296534ec795162c278e1b2a588cd68c192cef0a8a6d6fd5999cfd9bf7d5ffaf9"
      })
    end
  end

  context "writing cached digests" do
    it "writes successfully if there is no digests file" do
      digests = {
        1 => "296534ec795162c278e1b2a588cd68c192cef0a8a6d6fd5999cfd9bf7d5ffaf9"
      }
      empty_store.write_digests(digests)

      expect(empty_store.digests).to eq digests
    end

    it "overwrites the existing digests if a file already exists" do
      digests = {
        1 => "296534ec795162c278e1b2a588cd68c192cef0a8a6d6fd5999cfd9bf7d5ffaf9"
      }
      example_store.write_digests(digests)

      expect(example_store.digests).to eq digests
    end
  end

  context "reading configuration" do
    it "reads an empty hash if there is no configuration file" do
      expect(empty_store.configuration).to eq({})
    end

    it "reads the configuration from the config YAML file" do
      expect(example_store.configuration).to eq ({
        "site" => {
          "host" => "example.com"
        }
      })
    end
  end

  def store(name)
    Pressy::Store::FileStore.new(copy_store(name))
  end

  def copy_store(name)
    FileUtils.cp_r original_store_path(name), tmpdir
    File.join(tmpdir, name.to_s)
  end

  def original_store_path(name)
    File.join(STORE_FIXTURES_PATH, name.to_s)
  end
end
