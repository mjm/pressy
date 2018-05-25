class Pressy::RemoteChangeset
  def initialize
    @added_posts = []
    @local_posts = {}
    @server_posts = {}
  end

  def add_local_post(post)
    if post.id
      @local_posts[post.id] = post
    else
      @added_posts << post
    end
    self
  end

  def add_server_post(post)
    @server_posts[post.id] = post
    self
  end

  def has_changes?
    !(added_posts.empty? && updated_posts.empty? && deleted_posts.empty?)
  end

  def added_posts
    diff.added
  end

  def updated_posts
    diff.updated
  end

  def deleted_posts
    diff.deleted
  end

  private

  def diff
    @diff ||= build_diff
  end

  def build_diff
    updated_posts = @local_posts.select { |id, post| @server_posts.has_key?(id) && post != @server_posts[id] }

    Diff.new(@added_posts, updated_posts, {})
  end

  # @api private
  Diff = Struct.new(:added, :updated, :deleted)
end
