require 'pressy/changeset'

class Pressy::Action::Push
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
    changeset = Pressy::RemoteChangeset.new

    local_posts.each do |rendered, post|
      changeset.add_local_post(rendered, post)
    end

    @server_posts.each do |post|
      changeset.add_server_post(post)
    end

    changeset
  end

  def local_posts
    @local_posts.map {|post| [post, parse_local_post(post)] }
  end

  def parse_local_post(post)
    Pressy::PostParser.parse(format: post_format(post), content: post.content)
  end

  def post_format(post)
    File.dirname(post.path)
  end
end
