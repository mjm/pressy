require 'tempfile'

class Pressy::Editor
  def initialize(editor, console)
    @editor = editor
    @console = console
  end

  def edit(post)
    rendered_post = Pressy::PostRenderer.render(post)
    content = Tempfile.create(['draft', '.md']) do |file|
      file.write rendered_post.content
      file.fsync
      @console.run("#{@editor} \"#{file.path}\"")

      File.read(file.path)
    end

    Pressy::PostParser.parse(format: post.format, content: content)
  end
end
