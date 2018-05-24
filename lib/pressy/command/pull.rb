class Pressy::Command::Pull
  include Pressy::Command::ChangesetHelpers

  def self.name
    :pull
  end

  def initialize(site, stderr)
    @site = site
    @stderr = stderr
  end

  def run
    print_changeset(@site.pull.changeset, @stderr)
  end
end
