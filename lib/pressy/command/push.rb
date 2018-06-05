Pressy::Command.define :push do
  include Pressy::Command::ChangesetHelpers

  def run
    print_changeset site.push.changeset
  end
end
