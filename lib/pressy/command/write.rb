require 'optparse'

Pressy::Command.define :write do
  option :status, :s
  option :title, :t
  option :format, :f

  def run(options)
    site.create_post(editor.edit(empty_post(options)))
  end

  def empty_post(options)
    Pressy::EmptyPost.build(options)
  end

  def editor
    Pressy::Editor.new(env['EDITOR'], console)
  end

  def parse(args)
    options = {}
    OptionParser.new do |opts|
      opts.on('-s', '--status=STATUS') do |status|
        options[:status] = status
      end
      opts.on('-t', '--title=TITLE') do |title|
        options[:title] = title
      end
      opts.on('-f', '--format=FORMAT') do |format|
        options[:format] = format
      end
    end.parse!(args)
    options
  end
end
