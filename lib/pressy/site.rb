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

    push.changeset.changes.each do |change|
      change.execute(store, client)
    end

    push
  end

  # @!endgroup

  private

  def create_client
    @client = Pressy::Client.connect(site_configuration)
  end

  def site_configuration
    store.configuration["site"]&.transform_keys(&:to_sym) or raise "no site configuration found in this directory"
  end

  def fetch_local_posts
    store.all_posts
  end

  def fetch_server_posts
    client.fetch_posts.to_a
  end
end
