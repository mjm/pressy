class Pressy::Store::FileStore
  attr_reader :root

  def initialize(root)
    @root = root
  end

  def all_posts
    Dir.glob("**/*.md", base: root).map do |path|
      content = File.read(File.join(root, path))
      Pressy::RenderedPost.new(
        path,
        content,
        Digest::SHA256.hexdigest(content))
    end
  end

  def write(post)
    path = File.join(root, post.path)
    Dir.mkdir(File.dirname(path)) rescue nil
    File.write(path, post.content)
  end

  def digests
    YAML.load_file(File.join(root, ".pressy", "digests.yml")) rescue {}
  end
end
