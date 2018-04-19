require 'spec_helper'

RSpec.describe Pressy::PostsRenderer do
  let(:posts) {
    [
      make_status_post(500, "OMG that was amazing!", "publish"),
      make_status_post(501, "This is some cool #content.", "publish"),
      make_standard_post(502, "Making it Happen", "This is how you make it happen.", "publish"),
      make_standard_post(503, "How Do I Do It?", "I'm not really sure yet")
    ]
  }

  it "renders an empty list of posts" do
    result = Pressy::PostsRenderer.new([]).render
    expect(result.posts).to be_empty
  end

  it "renders a list of posts" do
    result = Pressy::PostsRenderer.new(posts).render
    expect(result.posts.count).to eq 4

    filenames = result.posts.map(&:path)
    expect(filenames).to eq %w{
      status/omg-that-was-amazing.md
      status/this-is-some-cool-content.md
      standard/making-it-happen.md
      standard/how-do-i-do-it.md
    }
  end

  def make_standard_post(id, title, content, status="draft")
    Wordpress::Post.new(
      "post_id" => id,
      "post_title" => title,
      "post_content" => content,
      "post_status" => status,
      "post_format" => "standard"
    )
  end

  def make_status_post(id, content, status="draft")
    Wordpress::Post.new(
      "post_id" => id,
      "post_content" => content,
      "post_status" => status,
      "post_format" => "status"
    )
  end
end
