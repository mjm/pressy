class Pressy::Command::Clone
  include Pressy::Command::ChangesetHelpers

  def self.name
    :clone
  end

  def initialize(site, console)
    @site = site
    @console = console
  end

  def run(url = nil, directory = nil)
    raise "no site URL provided" unless url

    username = @console.prompt("Username:")
    password = @console.prompt("Password:", echo: false)
    @console.error.puts

    new_site = @site.create(url: url, path: directory, username: username, password: password)
    @console.error.puts "Created new site in #{new_site.root}."

    pull = new_site.pull
    print_changeset pull.changeset, @console
  end
end
