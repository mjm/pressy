Pressy::Command.define :pull do
  include Pressy::Command::ChangesetHelpers

  def run(options)
    print_changeset site.pull.changeset
  end
end
