module Pressy::Command
  def self.define(command_name, &definition)
    class_name = command_name.capitalize
    command_class = Class.new
    self.const_set(class_name, command_class)
    command_class.class_eval %{
      def self.name
        #{command_name.inspect}
      end
    }
    command_class.include self
    command_class.class_eval(&definition)
    Registry.default.register(command_class)
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def initialize(site, console, env)
    @site = site
    @console = console
    @env = env
  end

  attr_reader :site, :console, :env

  def stdin
    console.input
  end

  def stdout
    console.output
  end

  def stderr
    console.error
  end

  module ClassMethods
    def option(long_name, short_name)
      @options ||= []
      @options << { key: long_name, long: long_name, short: short_name }
    end

    def parse!(args)
      options = {}
      OptionParser.new do |parser|
        add_options_to_parser(parser, options)
      end.parse!(args)
      options
    end

    private

    def add_options_to_parser(parser, options)
      (@options || []).each do |opt|
        parser.on("-#{opt[:short]}", "--#{opt[:long]}=#{opt[:long].upcase}") do |value|
          options[opt[:key]] = value
        end
      end
    end
  end

  module ChangesetHelpers
    def print_changeset(changeset)
      if changeset.has_changes?
        added = changeset.changes.count {|c| c.type == :add }
        updated = changeset.changes.count {|c| c.type == :update }
        deleted = changeset.changes.count {|c| c.type == :delete }
        stderr.puts "Added #{added} posts." unless added == 0
        stderr.puts "Updated #{updated} posts." unless updated == 0
        stderr.puts "Deleted #{deleted} posts." unless deleted == 0
      else
        stderr.puts "Already up-to-date."
      end
    end
  end
end

require 'pressy/command/registry'
require 'pressy/command/runner'

require 'pressy/command/clone'
require 'pressy/command/console'
require 'pressy/command/pull'
require 'pressy/command/push'
require 'pressy/command/write'
