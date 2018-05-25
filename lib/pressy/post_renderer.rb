require 'pressy/client'
require 'yaml'
require 'digest'
require 'time'

# PostRenderer transforms a Pressy::Post into a representation that can be
# written to a Store.
class Pressy::PostRenderer
  # Creates a new post renderer.
  # @param post [Pressy::Post] The post to render
  def initialize(post)
    @post = post
  end

  # Renders a post to a {Pressy::RenderedPost}.
  # @return [Pressy::RenderedPost] The rendered post
  def render
    Pressy::RenderedPost.new(path, content, digest)
  end

  # Creates a new renderer for a post, and returns the rendered post.
  # @param (see #initialize)
  # @return (see #render)
  def self.render(post)
    self.new(post).render
  end

  private

  def path
    File.join(@post.format, filename)
  end

  def filename
    Pressy::PostFilenameGenerator.new(@post.title, @post.content, @post.published_at).filename
  end

  def content
    @content ||= "#{YAML.dump(metadata)}---\n#{@post.content}"
  end

  def metadata
    {
      "id" => @post.id,
      "title" => @post.title.empty? ? nil : @post.title,
      "status" => @post.status,
      "published_at" => @post.published_at&.iso8601,
      "modified_at" => @post.modified_at&.iso8601,
    }.compact
  end

  def digest
    Digest::SHA256.hexdigest(content)
  end
end

# @api private
class Pressy::PostFilenameGenerator
  attr_reader :title, :content, :date

  def initialize(title, content, date=nil)
    @title = title
    @content = content
    @date = date
  end

  def filename
    "#{date_prefix}#{filename_components.join('-')}.md"
  end

  private

  def date_prefix
    if date
      date.strftime("%Y-%m-%d-")
    else
      ""
    end
  end

  def filename_components
    title.empty? ? content_components : title_components
  end

  HTML_TAGS = /<\/?[^>]*>/
  CHARACTERS_TO_STRIP = %r{[^a-z0-9 ]}
  SPACES = %r{\s+}

  def content_components
    content_lines
      .map {|s| s.gsub(CHARACTERS_TO_STRIP, '') }
      .reject {|s| s.strip.empty? }
      .first.split(SPACES).take(5)
  end

  def content_lines
    content_without_tags.split("\n")
  end

  def content_without_tags
    content.downcase.gsub(HTML_TAGS, "")
  end

  def title_components
    title.downcase.gsub(CHARACTERS_TO_STRIP, '').split(SPACES)
  end
end

# A RenderedPost represents a post as it is represented in a Store.
# @!attribute path
#   @return The file path where the post is stored
# @!attribute content
#   @return The rendered text content of the post
# @!attribute digest
#   @return The SHA256 hash of the post content
class Pressy::RenderedPost < Struct.new(:path, :content, :digest)
end
