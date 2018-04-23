class Pressy::Action::Pull
  attr_reader :server_posts

  def initialize(params)
    @local_posts = params.fetch(:local)
    @server_posts = params.fetch(:server)
  end

  def has_changes?
    !changed_posts.empty?
  end

  def changed_posts
    local = parsed_local_posts

    changes = []

    server_posts_by_id.each_pair do |id, post|
      local_post = local[id]
      if local_post
        rendered = Pressy::PostRenderer.render(post)
        if rendered.digest != local_post.original.digest
          changes << rendered
        end
      else
        changes << Pressy::PostRenderer.render(post)
      end
    end
    
    changes
  end

  private

  def local_posts
    @local_posts.map {|post| LocalPost.new(post, parse_local_post(post)) }
  end

  def parsed_local_posts
    local_posts.map {|p| [p.parsed.id, p]}.to_h
  end

  def parse_local_post(post)
    Pressy::PostParser.parse(format: post_format(post), content: post.content)
  end

  def post_format(post)
    File.dirname(post.path)
  end

  def server_posts_by_id
    server_posts.map {|p| [p.id, p]}.to_h
  end

  LocalPost = Struct.new(:original, :parsed)
end
