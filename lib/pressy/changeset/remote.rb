class Pressy::RemoteChangeset
  def initialize
    @added_posts = []
    @local_posts = {}
    @server_posts = {}
  end

  def add_local_post(rendered_post, post)
    if post.id
      @local_posts[post.id] = [rendered_post, post]
    else
      @added_posts << [rendered_post, post]
    end
    self
  end

  def add_server_post(post)
    @server_posts[post.id] = post
    self
  end

  def has_changes?
    !changes.empty?
  end

  def changes
    @changes ||= build_changes
  end

  private

  def build_changes
    added_posts + updated_posts
  end

  def added_posts
    @added_posts.map {|rendered,post| AddedPost.new(rendered, post) }
  end

  def updated_posts
    @local_posts
      .select {|id, post| @server_posts.has_key?(id) && post[1] != @server_posts[id] }
      .map {|id, post| UpdatedPost.new(*post) }
  end

  class AddedPost
    attr_reader :rendered_post, :post

    def initialize(rendered_post, post)
      @rendered_post = rendered_post
      @post = post
    end

    def execute(store, client)
      saved = client.create_post(post)
      rendered = Pressy::PostRenderer.render(saved)
      store.write(rendered)

      if rendered_post.path != rendered.path
        store.delete(rendered_post)
      end
    end

    def type
      :add
    end

    def ==(other)
      rendered_post == other.rendered_post && post == other.post
    end
  end

  class UpdatedPost
    attr_reader :rendered_post, :post

    def initialize(rendered_post, post)
      @rendered_post = rendered_post
      @post = post
    end

    def execute(store, client)
      saved = client.edit_post(post)
      rendered = Pressy::PostRenderer.render(saved)
      store.write(rendered)

      if rendered_post.path != rendered.path
        store.delete(rendered_post)
      end
    end

    def type
      :update
    end

    def ==(other)
      rendered_post == other.rendered_post && post == other.post
    end
  end
end
