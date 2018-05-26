module Pressy::Command
  module ChangesetHelpers
    def print_changeset(changeset, io)
      if changeset.has_changes?
        added = changeset.changes.count {|c| c.type == :add }
        updated = changeset.changes.count {|c| c.type == :update }
        deleted = changeset.changes.count {|c| c.type == :delete }
        io.puts "Added #{added} posts." unless added == 0
        io.puts "Updated #{updated} posts." unless updated == 0
        io.puts "Deleted #{deleted} posts." unless deleted == 0
      else
        io.puts "Already up-to-date."
      end
    end
  end
end

require 'pressy/command/runner'

require 'pressy/command/console'
require 'pressy/command/pull'
require 'pressy/command/push'
