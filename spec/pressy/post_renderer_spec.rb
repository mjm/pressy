require 'spec_helper'

RSpec.describe Pressy::PostRenderer do
  let(:post) {
    Pressy::Post.new(
      "post_id" => 123,
      "post_title" => "This is a post",
      "post_content" => %{This is my content. Isn't it cool},
      "post_type" => "post",
      "post_status" => "publish",
      "post_format" => "standard",
      "post_modified_gmt" => XMLRPC::DateTime.new(2018, 12, 25, 3, 3, 3),
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
    expect(rendered_post.content).to eq <<CONTENT.chomp
---
id: 123
title: This is a post
status: publish
modified_at: '2018-12-25T03:03:03Z'
---
This is my content. Isn't it cool
CONTENT
    expect(rendered_post.digest).to eq 'bb04ca995fdd609710038ef4bbae6c0c17a318549743f2278e3b6395ef86e993'
  end

  it "renders a status post" do
    rendered_post = Pressy::PostRenderer.render(status)
    expect(rendered_post.path).to eq "status/2018-12-25-this-is-my-status-update.md"
    expect(rendered_post.content).to eq <<CONTENT.chomp
---
id: 124
status: draft
published_at: '2018-12-25T01:01:01Z'
---
This is my status update #blessed
CONTENT
    expect(rendered_post.digest).to eq '60d9efabdb56a98487094cb2b8d1f768d05872cc26992b6acc38dbda8237b7f7'
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

  it "generates a filename with Markdown link URLs stripped out" do
    generator = Pressy::PostFilenameGenerator.new("", "I [saw a bird](https://example.com/this/is/a/bird) on the street the other day.")
    expect(generator.filename).to eq "i-saw-a-bird-on.md"
  end
end
