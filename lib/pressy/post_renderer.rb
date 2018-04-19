require 'wordpress'
require 'yaml'
require 'digest'

class Pressy::PostRenderer
  def initialize(post)
    @post = post
  end

  def render
    Pressy::RenderedPost.new(path, content, digest)
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
      @post.title.downcase.gsub(%r{[^a-z0-9 ]}, '').gsub(%r{ +}, '-')
    end
  end

  def content
    @content ||= <<~"CONTENT"
      #{YAML.dump(metadata)}---
      #{@post.content}
      CONTENT
  end

  def metadata
    {
      "id" => @post.id,
      "title" => @post.title.empty? ? nil : @post.title,
      "status" => @post.status
    }.compact
  end

  def digest
    Digest::SHA256.hexdigest(content)
  end
end

Pressy::RenderedPost = Struct.new(:path, :content, :digest)
