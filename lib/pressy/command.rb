module Pressy::Command
  module ChangesetHelpers
    def print_changeset(changeset, console)
      if changeset.has_changes?
        added = changeset.changes.count {|c| c.type == :add }
        updated = changeset.changes.count {|c| c.type == :update }
        deleted = changeset.changes.count {|c| c.type == :delete }
        console.error.puts "Added #{added} posts." unless added == 0
        console.error.puts "Updated #{updated} posts." unless updated == 0
        console.error.puts "Deleted #{deleted} posts." unless deleted == 0
      else
        console.error.puts "Already up-to-date."
      end
    end
  end
end

require 'pressy/command/runner'

require 'pressy/command/console'
require 'pressy/command/pull'
require 'pressy/command/push'
