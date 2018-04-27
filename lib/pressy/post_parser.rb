require 'wordpress'
require 'yaml'

# PostParser transforms the contents of a rendered post into a Wordpress::Post.
class Pressy::PostParser
  # @return [String] the format of the post, derived from the directory the post is stored in
  attr_reader :format
  # @return [IO] the rendered content of the post to parse
  attr_reader :content

  # Creates a new parser for a rendered post.
  # @option params [String] :format The format of the WordPress post
  # @option params [IO, String] :content The rendered content of the post
  def initialize(params)
    @format = params.fetch(:format)
    @content = params.fetch(:content)

    @content = StringIO.new(@content) if @content.is_a? String
  end

  # Parses the rendered post into a Wordpress::Post.
  # @return [Wordpress::Post] The post parsed from the given content
  def parse
    return Wordpress::Post.new("post_content" => "", "post_format" => format) if lines.empty?

    if lines.first.strip == "---"
      the_lines = lines.drop(1)
      frontmatter_end_idx = the_lines.index { |line| line.strip == "---" }
      frontmatter_lines = the_lines[0...frontmatter_end_idx]
      params = parse_frontmatter(frontmatter_lines)
      content = the_lines[(frontmatter_end_idx + 1)..-1]
      Wordpress::Post.new(params.merge("post_content" => content.join(""), "post_format" => format))
    else
      Wordpress::Post.new("post_content" => lines.join(""), "post_format" => format)
    end
  end

  # Creates a new parser with the given parameters, and returns the parsed post.
  # @note Equivalent to +Pressy::PostParser.new(params).parse+
  # @option (see #initialize)
  # @return (see #parse)
  def self.parse(params)
    self.new(params).parse
  end

  private

  def lines
    @lines ||= content.readlines
  end

  def parse_frontmatter(lines)
    frontmatter = YAML.load(lines.join("")) || {}
    {
      "post_id" => frontmatter["id"],
      "post_title" => frontmatter["title"],
      "post_status" => frontmatter["status"]
    }.compact
  end
end
