class Pressy::Command::Clone
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

    @site.clone(url: url, path: directory, username: username, password: password)
  end
end
