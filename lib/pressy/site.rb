require 'pressy/client'

# Site is a high-level interface for working with a WordPress site using Pressy.
class Pressy::Site
  # The Store that is managing the local storage for this site.
  # @return [Store]
  attr_reader :store

  # Creates a new Site backed by +store+.
  # Uses the configuration provided by +store+ to create a WordPress client
  # when needed.
  def initialize(store)
    @store = store
  end

  # The client that is being used to interact with the remote WordPress site.
  # @return [Pressy::Client]
  def client
    @client ||= create_client
  end

  def root
    store.root
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

  def create(params = {})
    uri = URI.parse(params.fetch(:url))

    site_config = {
      "host" => uri.host,
      "username" => params.fetch(:username),
      "password" => params.fetch(:password)
    }

    if uri.path != "" && uri.path != "/"
      # using File.join for this is sketchy but URI is very bad at joining
      site_config["path"] = File.join(uri.path, "xmlrpc.php")
    end

    new_store = store.create(params[:path] || uri.host, { "site" => site_config })
    Pressy::Site.new(new_store)
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
