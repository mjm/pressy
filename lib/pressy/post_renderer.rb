require 'wordpress'

class Pressy::PostRenderer
  def initialize(post)
    @post = post
  end

  def render
    Pressy::RenderedPost.new(path, content)
  end

  def path
    File.join(@post.format, filename)
  end

  def filename
    "#{path_friendly_title}.md"
  end

  def path_friendly_title
    if @post.title.empty?
      @post.content.downcase.gsub(%r{[^a-z0-9 ]}, '').split(%r{ +}).take(5).join('-')
    else
      @post.title.downcase.gsub(%r{[ /:]+}, '-')
    end
  end

  def content
    <<~"CONTENT"
      ---
      #{metadata}
      ---
      #{@post.content}
      CONTENT
  end

  def metadata
    lines = []
    lines << "id: #{@post.id}" if @post.id
    lines << "title: #{@post.title}" unless @post.title.empty?
    lines << "status: #{@post.status}"
    lines.join("\n")
  end
end

Pressy::RenderedPost = Struct.new(:path, :content)
