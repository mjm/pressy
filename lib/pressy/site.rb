class Pressy::Site
  attr_reader :store, :client

  def initialize(store)
    @store = store
    create_client
  end

  private

  def create_client
    @client = Wordpress.connect(store.configuration)
  end
end
