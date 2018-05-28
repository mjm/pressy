class Pressy::Command::Pull
  include Pressy::Command::ChangesetHelpers

  def self.name
    :pull
  end

  def initialize(site, console)
    @site = site
    @console = console
  end

  def run
    print_changeset(@site.pull.changeset, @console)
  end
end
