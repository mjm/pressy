module Pressy::Command
  def self.define(command_name, &definition)
    class_name = command_name.capitalize
    command_class = Class.new(&definition)
    self.const_set(class_name, command_class)
    command_class.class_eval %{
      def self.name
        #{command_name.inspect}
      end
    }
    command_class.include Pressy::Command
  end

  def initialize(site, console)
    @site = site
    @console = console
  end

  attr_reader :site, :console

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

require 'pressy/command/clone'
require 'pressy/command/console'
require 'pressy/command/pull'
require 'pressy/command/push'
