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

  def self.render(post)
    self.new(post).render
  end

  private

  def path
    File.join(@post.format, filename)
  end

  def filename
    "#{filename_components.join('-')}.md"
  end

  def filename_components
    @post.title.empty? ? content_components : title_components
  end

  HTML_TAGS = /<\/?[^>]*>/
  CHARACTERS_TO_STRIP = %r{[^a-z0-9 ]}
  SPACES = %r{\s+}

  def content_components
    content_without_tags.split("\n").map{ |s| s.gsub(CHARACTERS_TO_STRIP, '') }
      .reject {|s| s.strip.empty? }
      .first.split(SPACES).take(5)
  end

  def content_without_tags
    @post.content.downcase.gsub(HTML_TAGS, "")
  end

  def title_components
    @post.title.downcase.gsub(CHARACTERS_TO_STRIP, '').split(SPACES)
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
