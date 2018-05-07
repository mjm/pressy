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
    expect(result.digests).to eq({})
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

    expect(result.digests).to eq({
      500 => "498111fb48f68d6ebcef2e337d440418e68cf5672182369285831f650f77c784",
      501 => "32475ed54374c11067f0305fc82ea24c1d5996f8351b92fb8b28f9ea3bf3fc9c",
      502 => "af51b9933eff030e507bb06374420e38cf97a9432039630c107682f27c87e026",
      503 => "7a23e8d4c85e421b7341a38d4dbcf6c203e6a9b69e996c3eb280187d0c152713",
    })
  end

  def make_standard_post(id, title, content, status="draft")
    Pressy::Post.new(
      "post_id" => id,
      "post_title" => title,
      "post_content" => content,
      "post_status" => status,
      "post_format" => "standard"
    )
  end

  def make_status_post(id, content, status="draft")
    Pressy::Post.new(
      "post_id" => id,
      "post_content" => content,
      "post_status" => status,
      "post_format" => "status"
    )
  end
end
