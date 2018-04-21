require 'spec_helper'

RSpec.describe Pressy::PostParser do
  it "parses an empty post" do
    content = ""
    post = Pressy::PostParser.parse(format: 'standard', content: content)

    expect(post.content).to eq ''
    expect(post.format).to eq 'standard'
  end

  it "parses a post with no metadata" do
    content = "This is my post.\n\nHere is a second paragraph."
    post = Pressy::PostParser.parse(format: 'status', content: content)

    expect(post.content).to eq content
    expect(post.format).to eq 'status'
  end

  it "parses a post with only metadata" do
    content = <<~CONTENT
      ---
      id: 1234
      title: This is my post title
      status: publish
      ---
      CONTENT
    post = Pressy::PostParser.parse(format: 'standard', content: content)

    expect(post.id).to eq 1234
    expect(post.title).to eq "This is my post title"
    expect(post.status).to eq "publish"
    expect(post.format).to eq "standard"
    expect(post.content).to eq ""
  end

  it "parses a post with empty metadata" do
    content = <<~CONTENT
      ---
      ---
      This is my post content.
      CONTENT
    post = Pressy::PostParser.parse(format: 'standard', content: content)

    expect(post.id).to be_nil
    expect(post.title).to be_empty
    expect(post.status).to eq "draft"
    expect(post.format).to eq "standard"
    expect(post.content).to eq "This is my post content.\n"
  end

  it "parses a post with partial metadata" do
    content = <<~CONTENT
      ---
      title: Foo
      ---
      This is my post content.
      CONTENT
    post = Pressy::PostParser.parse(format: 'standard', content: content)

    expect(post.id).to be_nil
    expect(post.title).to eq "Foo"
    expect(post.status).to eq "draft"
    expect(post.format).to eq "standard"
    expect(post.content).to eq "This is my post content.\n"
  end

  it "parses a standard post" do
    content = <<~CONTENT
      ---
      id: 1234
      title: This is my post title
      status: publish
      ---
      This is my post contents.

      I really like blogging with Pressy!
      CONTENT
    post = Pressy::PostParser.parse(format: 'standard', content: content)

    expect(post.id).to eq 1234
    expect(post.title).to eq "This is my post title"
    expect(post.status).to eq "publish"
    expect(post.format).to eq "standard"
    expect(post.content).to eq "This is my post contents.\n\nI really like blogging with Pressy!\n"
  end
end
