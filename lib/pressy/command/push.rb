class Pressy::Command::Push
  include Pressy::Command::ChangesetHelpers

  def self.name
    :push
  end

  def initialize(site, console)
    @site = site
    @console = console
  end

  def run
    print_changeset(@site.push.changeset, @console)
  end
end
