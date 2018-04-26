class Pressy::Site
  attr_reader :store, :client

  def initialize(store)
    @store = store
    create_client
  end

  def pull
    pull = Pressy::Action::Pull.new(
      local: fetch_local_posts,
      server: fetch_server_posts
    )

    digests = {}
    pull.changed_posts.each_pair do |id, post|
      store.write(post)
      digests[id] = post.digest
    end

    store.write_digests(digests) if pull.has_changes?

    Pressy::PullResult.new(pull)
  end

  private

  def create_client
    @client = Wordpress.connect(store.configuration)
  end

  def fetch_local_posts
    store.all_posts
  end

  def fetch_server_posts
    client.fetch_posts.to_a
  end
end

class Pressy::PullResult
  def initialize(pull)
    @has_changes = pull.has_changes?
  end

  def has_changes?
    @has_changes
  end
end
