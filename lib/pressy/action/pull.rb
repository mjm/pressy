require 'pressy/changeset'

class Pressy::Action::Pull
  attr_reader :server_posts

  def initialize(params)
    @local_posts = params.fetch(:local)
    @server_posts = params.fetch(:server)
  end

  def has_changes?
    changeset.has_changes?
  end

  def changeset
    @changeset ||= build_changeset
  end

  private

  def build_changeset
    changes = Pressy::LocalChangeset.new

    local_posts.each do |local_post|
      changes.add_local_post(local_post.parsed.id, local_post.original)
    end

    server_posts.each do |post|
      rendered = Pressy::PostRenderer.render(post)
      changes.add_server_post(post.id, rendered)
    end

    changes
  end

  def local_posts
    @local_posts.map {|post| LocalPost.new(post, parse_local_post(post)) }
  end

  def parse_local_post(post)
    Pressy::PostParser.parse(format: post_format(post), content: post.content)
  end

  def post_format(post)
    File.dirname(post.path)
  end

  LocalPost = Struct.new(:original, :parsed)
end
