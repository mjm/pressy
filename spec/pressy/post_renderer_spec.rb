require 'spec_helper'

RSpec.describe Pressy::PostRenderer do
  let(:post) {
    Wordpress::Post.new(
      "post_id" => 123,
      "post_title" => "This is a post",
      "post_content" => %{This is my content. Isn't it cool},
      "post_type" => "post",
      "post_format" => "standard"
    )
  }
  let(:status) {
    Wordpress::Post.new(
      "post_id" => 124,
      "post_title" => "",
      "post_content" => %{This is my status update #blessed},
      "post_type" => "post",
      "post_format" => "status"
    )
  }

  it "renders a standard post" do
    rendered_post = Pressy::PostRenderer.new(post).render
    expect(rendered_post.path).to eq "standard/this-is-a-post.md"
    expect(rendered_post.content).to eq <<CONTENT
---
id: 123
title: This is a post
---
This is my content. Isn't it cool
CONTENT
  end

  it "renders a status post" do
    rendered_post = Pressy::PostRenderer.new(status).render
    expect(rendered_post.path).to eq "status/this-is-my-status-update.md"
    expect(rendered_post.content).to eq <<CONTENT
---
id: 124
---
This is my status update #blessed
CONTENT
  end
end
