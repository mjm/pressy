require 'wordpress'
require 'yaml'

class Pressy::PostParser
  attr_reader :format, :content

  def initialize(params)
    @format = params.fetch(:format)
    @content = params.fetch(:content)

    @content = StringIO.new(@content) if @content.is_a? String
  end

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
