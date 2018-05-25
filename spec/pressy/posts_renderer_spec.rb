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
       500 => "a2380f1f1e6939a9a82138c1ed942ca6484e3d586328a50741760110ec662847",
       501 => "f4fdb7ccaafd00305bed951990b748593a1ba442f5cdfd450e847975e525ab95",
       502 => "9af080565e23af1621df412f20aa1ab8bdd5debfa87d1d1628cc0f779d293974",
       503 => "5b2397ee0778129c0cbb59a76c18f4364fae5c65345a062c14a9a5b0827386b3",
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
