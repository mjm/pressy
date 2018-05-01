# Site is a high-level interface for working with a WordPress site using Pressy.
class Pressy::Site
  # The Store that is managing the local storage for this site.
  # @return [Store]
  attr_reader :store
  # The client that is being used to interact with the remote WordPress site.
  # @return [Wordpress]
  attr_reader :client

  # Creates a new Site backed by +store+.
  # Uses the configuration provided by +store+ to create a WordPress client.
  def initialize(store)
    @store = store
    create_client
  end

  # @!group Actions

  # Checks for changes on the server and updates the files on disk to match.
  def pull
    pull = Pressy::Action::Pull.new(
      local: fetch_local_posts,
      server: fetch_server_posts
    )

    digests = {}
    posts = pull.changeset.added_posts.merge(pull.changeset.updated_posts)
    posts.each_pair do |id, post|
      store.write(post)
      digests[id] = post.digest
    end

    store.write_digests(digests) if pull.has_changes?

    pull
  end

  # @!endgroup

  private

  def create_client
    @client = Wordpress.connect(site_configuration)
  end

  def site_configuration
    store.configuration["site"].transform_keys(&:to_sym)
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
