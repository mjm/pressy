require 'spec_helper'

RSpec.describe Pressy::Command::Write do
  include_examples "command", :write

  let(:env) { { "EDITOR" => "vi" } }

  let(:post) { double(:post) }
  let(:edited_post) { double(:edited_post) }
  let(:editor) { instance_double("Pressy::Editor") }

  it "parses the short-form options" do
    args = %w(-s foo -t bar -f baz a b c)
    expect(described_class.parse!(args)).to eq({
      status: "foo",
      title: "bar",
      format: "baz"
    })
    expect(args).to eq %w(a b c)
  end

  it "parses the long-form options" do
    args = %w(--status=foo --title=bar --format baz a b c)
    expect(described_class.parse!(args)).to eq({
      status: "foo",
      title: "bar",
      format: "baz"
    })
    expect(args).to eq %w(a b c)
  end

  context "when no arguments are provided" do
    it "builds an empty post with no options and edits it" do
      verify_write({})
      subject.run({})
    end
  end

  context "when the status is overridden" do
    it "builds an empty post with the status option and edits it" do
      verify_write status: "publish"
      subject.run(status: "publish")
    end
  end

  context "when the title is overridden" do
    it "builds an empty post with the title option and edits it" do
      verify_write title: "My cool title"
      subject.run(title: "My cool title")
    end
  end

  context "when the format is overridden" do
    it "builds an empty post with the format option and edits it" do
      verify_write format: "status"
      subject.run(format: "status")
    end
  end

  def verify_write(expected_options)
    expect(Pressy::EmptyPost).to receive(:build).with(expected_options) { post }
    expect(Pressy::Editor).to receive(:new).with("vi", console) { editor }
    expect(editor).to receive(:edit).with(post) { edited_post }
    expect(site).to receive(:create_post).with(edited_post)
  end
end
