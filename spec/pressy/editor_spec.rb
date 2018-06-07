require 'spec_helper'

RSpec.describe Pressy::Editor do
  let(:console) { instance_double("Pressy::Console") }
  let(:editor) { "vi" }

  let(:empty_post) {
    Pressy::Post.new(
      "post_title" => "My title",
      "post_content" => "\n",
      "post_status" => "publish",
      "post_format" => "status",
    )
  }

  subject { Pressy::Editor.new(editor, console) }

  it "edits a temporary file with the rendered post" do
    verify_edit_command do |filename|
      contents = File.read(filename)
      contents.sub!('title: My title', 'title: A different title')
      contents.sub!('status: publish', 'status: draft')
      contents.sub!("\n---\n", "\n---\nThis is some draft content")
      File.write(filename, contents)
    end

    post = subject.edit(empty_post)
    expect(post.format).to eq 'status'
    expect(post.title).to eq 'A different title'
    expect(post.status).to eq 'draft'
    expect(post.content).to eq "This is some draft content\n"
  end

  def verify_edit_command
    expect(console).to receive(:run) do |command|
      expect(command).to start_with("vi \"")
      expect(command).to end_with("\"")

      @filename = command[4..-2]
      basename = File.basename(@filename)
      expect(basename).to start_with("draft")
      expect(basename).to end_with(".md")

      contents = File.read(@filename)
      expect(contents).to include('title: My title')

      yield @filename
    end
  end
end
