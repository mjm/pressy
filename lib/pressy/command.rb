module Pressy::Command
  module ChangesetHelpers
    def print_changeset(changeset, io)
      if changeset.has_changes?
        io.puts "Added #{changeset.added_posts.count} posts." unless changeset.added_posts.empty?
        io.puts "Updated #{changeset.updated_posts.count} posts." unless changeset.updated_posts.empty?
        io.puts "Deleted #{changeset.deleted_posts.count} posts." unless changeset.deleted_posts.empty?
      else
        io.puts "Already up-to-date."
      end
    end
  end
end

require 'pressy/command/pull'
require 'pressy/command/push'
