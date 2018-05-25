require 'spec_helper'

RSpec.describe Pressy::RemoteChangeset do
  context "an empty changeset" do
    subject { Pressy::RemoteChangeset.new }

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
    let(:new_post) { double(:new_post, id: nil) }

    subject {
      Pressy::RemoteChangeset.new
        .add_local_post(new_post)
    }

    it "has changes" do
      expect(subject).to have_changes
    end

    it "has an added post" do
      expect(subject.added_posts).to eq [new_post]
    end

    it "has no updated posts" do
      expect(subject.updated_posts).to be_empty
    end

    it "has no deleted posts" do
      expect(subject.deleted_posts).to be_empty
    end
  end

  context "a changeset with an unchanged post" do
    let(:local_post) { double(:local_post, id: 1) }
    let(:server_post) { double(:server_post, id: 1) }

    subject {
      Pressy::RemoteChangeset.new
        .add_local_post(local_post)
        .add_server_post(server_post)
    }

    before do
      allow(local_post).to receive(:==) {|other| other.equal? server_post }
    end

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

  context "a changeset with an updated post" do
    let(:local_post) { double(:local_post, id: 1) }
    let(:server_post) { double(:server_post, id: 1) }

    subject {
      Pressy::RemoteChangeset.new
        .add_local_post(local_post)
        .add_server_post(server_post)
    }

    before do
      allow(local_post).to receive(:==) { false }
    end

    it "has changes" do
      expect(subject).to have_changes
    end

    it "has no added posts" do
      expect(subject.added_posts).to be_empty
    end

    it "has an updated post" do
      expect(subject.updated_posts).to eq({ 1 => local_post })
    end

    it "has no deleted posts" do
      expect(subject.deleted_posts).to be_empty
    end
  end
end
