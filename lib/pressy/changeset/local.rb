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
    @changes = nil
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
    @changes = nil
    self
  end

  # @!endgroup
  # @!group Querying the Changes

  # Checks if there are differences present in the changeset.
  # @return [Boolean] true if there are any differences between the local and server posts
  def has_changes?
    !changes.empty?
  end

  # @return [Array<AddedPost, UpdatedPost, DeletedPost>]
  #   a list of changes to apply to the store
  def changes
    @changes ||= build_changes
  end

  # @!endgroup

  private

  def build_changes
    added_posts + updated_posts + deleted_posts
  end

  def added_posts
    @server_posts
      .reject {|id, post| @local_posts.has_key? id }
      .map {|id, post| AddedPost.new(id, post) }
  end

  def updated_posts
    @server_posts
      .select {|id, post| @local_posts[id] && @local_posts[id].digest != post.digest }
      .map {|id, post| UpdatedPost.new(id, @local_posts[id], post) }
  end

  def deleted_posts
    @local_posts
      .reject {|id, post| @server_posts.has_key? id }
      .map {|id, post| DeletedPost.new(id, post) }
  end

  class AddedPost
    attr_reader :id, :post

    def initialize(id, post)
      @id = id
      @post = post
    end

    def execute(store)
      store.write(id, post)
    end

    def type
      :add
    end

    def ==(other)
      id == other.id && post == other.post
    end
  end

  class UpdatedPost
    attr_reader :id, :existing_post, :updated_post

    def initialize(id, existing, updated)
      @id = id
      @existing_post = existing
      @updated_post = updated
    end

    def execute(store)
      if existing_post.path != updated_post.path
        store.delete(id, existing_post)
      end

      store.write(id, updated_post)
    end

    def type
      :update
    end

    def ==(other)
      existing_post == other.existing_post && updated_post == other.updated_post
    end
  end

  class DeletedPost
    attr_reader :id, :post

    def initialize(id, post)
      @id = id
      @post = post
    end

    def execute(store)
      store.delete(id, post)
    end

    def type
      :delete
    end

    def ==(other)
      post == other.post
    end
  end
end
