# FileStore is the default Store for Pressy sites.
#
# FileStore saves each post as a file on disk. It also creates a +.pressy+ folder
# to hold the digests and configuration for the site in YAML format.
class Pressy::Store::FileStore
  # The root directory of the site.
  # This directory should contain the +.pressy+ directory.
  # @return [String]
  attr_reader :root

  # Creates a new file store with the given root directory.
  # @param root [String] The root directory of the site.
  def initialize(root)
    @root = root
  end

  # @return [Array<Pressy::RenderedPost>] all of the posts found on disk
  def all_posts
    Dir.glob("**/*.md", base: root).map do |path|
      content = File.read(File.join(root, path))
      Pressy::RenderedPost.new(
        path,
        content,
        Digest::SHA256.hexdigest(content))
    end
  end

  # Writes a rendered post to disk.
  # @param post [Pressy::RenderedPost] the post to write
  def write(post)
    path = post_path(post)
    create_parent_directory path
    File.write(path, post.content)
  end

  # Deletes a post from disk.
  # @param post [Pressy::RenderedPost] the post to delete
  def delete(post)
    File.unlink(post_path(post))
  end

  # @return [Hash] the saved digests for each post, by ID
  def digests
    YAML.load_file(digests_path) rescue {}
  end

  # Writes new digests for the site's posts to disk.
  # @param digests [Hash] the complete mapping from post ID to digest
  def write_digests(digests)
    create_parent_directory digests_path
    File.write(digests_path, YAML.dump(digests))
  end

  # @return [Hash] the saved configuration of the site
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
