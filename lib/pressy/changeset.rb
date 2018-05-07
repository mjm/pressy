# A LocalChangeset holds set of changes to apply to a local Store.
class Pressy::LocalChangeset
  # Creates a new, empty changeset.
  def initialize
    @server_posts = {}
    @local_posts = {}
  end

  # @!group Building the Changeset

  # Adds a rendered post from the server to the changeset.
  #
  # If no local post is added with the same id, the post will be present in
  # {#added_posts}.
  #
  # If a local post is added with the same id, the post may be present in
  # {#updated_posts} if it was changed on the server.
  #
  # @return [self] the updated changeset
  def add_server_post(id, post)
    @server_posts[id] = post
    @diff = nil
    self
  end

  # Adds a rendered post from the local store to the changeset.
  #
  # If the id is nil, the post is a local-only draft and will be ignored.
  #
  # If no server post is added with the same id, this post will be present in
  # {#deleted_posts}.
  #
  # If a server post is added with the same id, the post may be present in
  # {#updated_posts} if it was changed on the server.
  #
  # @return [self] the updated changeset
  def add_local_post(id, post)
    return self unless id

    @local_posts[id] = post
    @diff = nil
    self
  end

  # @!endgroup
  # @!group Querying the Changes

  # Checks if there are differences present in the changeset.
  # @return [Boolean] true if there are any differences between the local and server posts
  def has_changes?
    !(diff.added.empty? && diff.updated.empty? && diff.deleted.empty?)
  end

  # @return [Hash{Fixnum => Pressy::RenderedPost}]
  #   a list of posts to create in the store
  def added_posts
    diff.added
  end

  # @return [Hash{Fixnum => Pressy::RenderedPost}]
  #   a list of posts to update in the store
  def updated_posts
    diff.updated
  end

  # @return [Hash{Fixnum => Pressy::RenderedPost}]
  #   a list of posts to remove from the store
  def deleted_posts
    diff.deleted
  end

  # @!endgroup
  
  private

  def diff
    @diff ||= build_diff
  end

  def build_diff
    added = @server_posts.reject {|id, post| @local_posts.has_key? id }
    updated = @server_posts
      .select {|id, post| @local_posts[id] && @local_posts[id].digest != post.digest }
    deleted = @local_posts.reject {|id, post| @server_posts.has_key? id }

    Diff.new(added, updated, deleted)
  end

  # @api private
  Diff = Struct.new(:added, :updated, :deleted)
end

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
