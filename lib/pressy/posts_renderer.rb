require 'pressy/post_renderer'

class Pressy::PostsRenderer
  attr_reader :posts

  def initialize(posts)
    @posts = posts
  end

  def render
    Pressy::RenderedPosts.new(rendered_posts, digests)
  end

  private

  def rendered_posts_by_id
    @rendered_posts_by_id ||=
      Hash[posts.map { |post| [post.id, Pressy::PostRenderer.new(post).render] }]
  end

  def rendered_posts
    rendered_posts_by_id.values
  end

  def digests
    rendered_posts_by_id.transform_values(&:digest)
  end
end

Pressy::RenderedPosts = Struct.new(:posts, :digests)
