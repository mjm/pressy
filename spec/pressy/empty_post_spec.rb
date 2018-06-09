require 'spec_helper'

RSpec.describe Pressy::EmptyPost do
  it "builds an empty post with no options" do
    post = Pressy::EmptyPost.build
    expect(post.title).to eq ''
    expect(post.content).to eq "\n"
    expect(post.status).to eq "draft"
    expect(post.format).to eq "standard"
  end

  it "builds a post with an overridden title" do
    post = Pressy::EmptyPost.build(title: "Foo bar")
    expect(post.title).to eq "Foo bar"
  end

  it "builds a post with an overridden status" do
    post = Pressy::EmptyPost.build(status: "publish")
    expect(post.status).to eq "publish"
  end

  it "builds a post with an overridden format" do
    post = Pressy::EmptyPost.build(format: "status")
    expect(post.format).to eq "status"
  end
end
