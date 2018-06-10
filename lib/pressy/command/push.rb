Pressy::Command.define :push do
  include Pressy::Command::ChangesetHelpers

  def run(options)
    print_changeset site.push.changeset
  end
end
