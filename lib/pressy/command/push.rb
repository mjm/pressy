class Pressy::Command::Push
  include Pressy::Command::ChangesetHelpers

  def self.name
    :push
  end

  def initialize(site, stderr)
    @site = site
    @stderr = stderr
  end

  def run
    print_changeset(@site.push.changeset, @stderr)
  end
end
