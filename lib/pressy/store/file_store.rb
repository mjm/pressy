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
    path = post_path(post)
    create_parent_directory path
    File.write(path, post.content)
  end

  def digests
    YAML.load_file(digests_path) rescue {}
  end

  def write_digests(digests)
    create_parent_directory digests_path
    File.write(digests_path, YAML.dump(digests))
  end

  def configuration
    YAML.load_file(configuration_path) rescue {}
  end

  private

  def post_path(post)
    File.join(root, post.path)
  end

  def digests_path
    File.join(root, ".pressy", "digests.yml")
  end

  def configuration_path
    File.join(root, ".pressy", "config.yml")
  end

  def create_parent_directory(path)
    Dir.mkdir(File.dirname(path)) rescue nil
  end
end
