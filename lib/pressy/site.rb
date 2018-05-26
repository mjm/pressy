require 'pressy/client'

# Site is a high-level interface for working with a WordPress site using Pressy.
class Pressy::Site
  # The Store that is managing the local storage for this site.
  # @return [Store]
  attr_reader :store
  # The client that is being used to interact with the remote WordPress site.
  # @return [Pressy::Client]
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

    pull.changeset.changes.each do |change|
      change.execute(store)
    end

    pull
  end

  # Checks for local changes and sends them to the server.
  def push
    push = Pressy::Action::Push.new(
      local: fetch_local_posts,
      server: fetch_server_posts
    )

    push.changeset.added_posts.each do |post|
      saved_post = client.create_post(post)
      # Calling the renderer here feels kinda like a layering violation, but the other layers
      # won't have the Client, so they wouldn't be able to provide us the already rendered post
      store.write(Pressy::PostRenderer.render(saved_post))
    end

    push.changeset.updated_posts.each do |_, post|
      saved_post = client.edit_post(post)
      store.write(Pressy::PostRenderer.render(saved_post))
    end

    push
  end

  # @!endgroup

  private

  def create_client
    @client = Pressy::Client.connect(site_configuration)
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
