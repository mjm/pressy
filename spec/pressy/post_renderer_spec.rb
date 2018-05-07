require 'spec_helper'

RSpec.describe Pressy::PostRenderer do
  let(:post) {
    Pressy::Post.new(
      "post_id" => 123,
      "post_title" => "This is a post",
      "post_content" => %{This is my content. Isn't it cool},
      "post_type" => "post",
      "post_status" => "publish",
      "post_format" => "standard"
    )
  }
  let(:status) {
    Pressy::Post.new(
      "post_id" => 124,
      "post_title" => "",
      "post_content" => %{This is my status update #blessed},
      "post_type" => "post",
      "post_format" => "status",
      "post_date_gmt" => XMLRPC::DateTime.new(2018, 12, 25, 1, 1, 1)
    )
  }

  it "renders a standard post" do
    rendered_post = Pressy::PostRenderer.render(post)
    expect(rendered_post.path).to eq "standard/this-is-a-post.md"
    expect(rendered_post.content).to eq <<CONTENT
---
id: 123
title: This is a post
status: publish
---
This is my content. Isn't it cool
CONTENT
    expect(rendered_post.digest).to eq 'a3ba2cc9a4b22cd7632df3ff450d12e5a6ccbe3da4ac0dcdc054ce46f1ef67c9'
  end

  it "renders a status post" do
    rendered_post = Pressy::PostRenderer.render(status)
    expect(rendered_post.path).to eq "status/2018-12-25-this-is-my-status-update.md"
    expect(rendered_post.content).to eq <<CONTENT
---
id: 124
status: draft
---
This is my status update #blessed
CONTENT
    expect(rendered_post.digest).to eq 'ee821faa47aec9f8d042495fef35297241d5abdc73aa0869931535f3a8d994c7'
  end

  it "produces the same digest for the same post" do
    rendered_post = Pressy::PostRenderer.render(post)
    rendered_post2 = Pressy::PostRenderer.render(Pressy::Post.new(post.fields))
    expect(rendered_post.digest).to eq rendered_post2.digest
  end
end

RSpec.describe Pressy::PostFilenameGenerator do
  it "generates a filename for a post with a title" do
    generator = Pressy::PostFilenameGenerator.new("This is a post", "Blah blah")
    expect(generator.filename).to eq "this-is-a-post.md"
  end

  it "generates a filename from basic post content" do
    generator = Pressy::PostFilenameGenerator.new("", "This is my #status #update. #blessed")
    expect(generator.filename).to eq "this-is-my-status-update.md"
  end

  it "generates a filename stripped of HTML" do
    generator = Pressy::PostFilenameGenerator.new("", %Q{
<div class="e-content">
Foo bar
</div>
[gallery size=full columns=1]
})
    expect(generator.filename).to eq "foo-bar.md"
  end

  it "generates a filename from only the first line of content" do
    generator = Pressy::PostFilenameGenerator.new("", "This is\nmy post")
    expect(generator.filename).to eq "this-is.md"
  end

  it "generates a filename with the post date" do
    date = Time.utc(2018, 1, 1, 8, 0, 0)
    generator = Pressy::PostFilenameGenerator.new("Foo bar baz", "Whatever", date)
    expect(generator.filename).to eq "2018-01-01-foo-bar-baz.md"
  end
end
