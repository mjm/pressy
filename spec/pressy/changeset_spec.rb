require 'spec_helper'

RSpec.describe Pressy::LocalChangeset do
  context "an empty changeset" do
    subject { Pressy::LocalChangeset.new }

    it "has no changes" do
      expect(subject).not_to have_changes
    end

    it "has no added posts" do
      expect(subject.added_posts).to be_empty
    end

    it "has no updated posts" do
      expect(subject.updated_posts).to be_empty
    end

    it "has no deleted posts" do
      expect(subject.deleted_posts).to be_empty
    end
  end

  context "a changeset with one new post" do
    let(:new_post) { double(:post, digest: "abc") }

    subject do
      changes = Pressy::LocalChangeset.new
      changes.add_server_post(123, new_post)
    end

    it "has changes" do
      expect(subject).to have_changes
    end

    it "has an added post" do
      expect(subject.added_posts).to eq({ 123 => new_post })
    end

    it "has no updated posts" do
      expect(subject.updated_posts).to be_empty
    end

    it "has no deleted posts" do
      expect(subject.deleted_posts).to be_empty
    end
  end

  context "a changeset with one deleted post" do
    let(:deleted_post) { double(:post, digest: "abc") }

    subject { Pressy::LocalChangeset.new.add_local_post(123, deleted_post) }

    it "has changes" do
      expect(subject).to have_changes
    end

    it "has no added posts" do
      expect(subject.added_posts).to be_empty
    end

    it "has no updated posts" do
      expect(subject.updated_posts).to be_empty
    end

    it "has a deleted post" do
      expect(subject.deleted_posts).to eq({ 123 => deleted_post })
    end
  end

  context "a changeset with an unchanged post" do
    let(:post) { double(:post, digest: "abc") }

    subject {
      Pressy::LocalChangeset.new
        .add_local_post(123, post)
        .add_server_post(123, post)
    }

    it "has no changes" do
      expect(subject).not_to have_changes
    end

    it "has no added posts" do
      expect(subject.added_posts).to be_empty
    end

    it "has no updated posts" do
      expect(subject.updated_posts).to be_empty
    end

    it "has no deleted posts" do
      expect(subject.deleted_posts).to be_empty
    end
  end

  context "a changeset with a changed post" do
    let(:local_post) { double(:local_post, digest: "abc") }
    let(:server_post) { double(:server_post, digest: "def") }

    subject {
      Pressy::LocalChangeset.new
        .add_local_post(123, local_post)
        .add_server_post(123, server_post)
    }

    it "has changes" do
      expect(subject).to have_changes
    end

    it "has no added posts" do
      expect(subject.added_posts).to be_empty
    end

    it "has an updated post" do
      # TODO this should probably return something that includes the original post
      # that way we can move the post if the filename changed
      expect(subject.updated_posts).to eq({ 123 => server_post })
    end

    it "has no deleted posts" do
      expect(subject.deleted_posts).to be_empty
    end
  end

  it "updates the diff results when posts are added" do
    changes = Pressy::LocalChangeset.new
    expect(changes.added_posts).to be_empty
    changes.add_server_post(123, double(:post, digest: "abc"))
    expect(changes.added_posts).not_to be_empty
    changes.add_local_post(123, double(:post, digest: "abc"))
    expect(changes.added_posts).to be_empty
  end
end