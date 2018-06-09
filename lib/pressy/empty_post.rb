module Pressy::EmptyPost
  def self.build(options = {})
    Pressy::Post.new(
      "post_title" => options[:title],
      "post_content" => "\n",
      "post_status" => options.fetch(:status, "draft"),
      "post_format" => options.fetch(:format, "standard"),
    )
  end
end
