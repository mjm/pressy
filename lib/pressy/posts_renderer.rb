require 'pressy/post_renderer'

class Pressy::PostsRenderer
  attr_reader :posts

  def initialize(posts)
    @posts = posts
  end

  def render
    Pressy::RenderedPosts.new(rendered_posts)
  end

  private

  def rendered_posts
    posts.map {|post| Pressy::PostRenderer.new(post).render }
  end
end

Pressy::RenderedPosts = Struct.new(:posts)
