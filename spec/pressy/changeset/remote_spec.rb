require 'spec_helper'

RSpec.describe Pressy::RemoteChangeset do
  context "an empty changeset" do
    subject { Pressy::RemoteChangeset.new }

    it "has no changes" do
      expect(subject).not_to have_changes
      expect(subject.changes).to eq []
    end
  end

  context "a changeset with one new post" do
    let(:draft_post) { double(:draft_post) }
    let(:new_post) { double(:new_post, id: nil) }

    subject {
      Pressy::RemoteChangeset.new
        .add_local_post(draft_post, new_post)
    }

    it "has an added post" do
      expect(subject).to have_changes
      expect(subject.changes).to eq [
        Pressy::RemoteChangeset::AddedPost.new(draft_post, new_post)
      ]
    end
  end

  context "a changeset with an unchanged post" do
    let(:draft_post) { double(:draft_post) }
    let(:local_post) { double(:local_post, id: 1) }
    let(:server_post) { double(:server_post, id: 1) }

    subject {
      Pressy::RemoteChangeset.new
        .add_local_post(draft_post, local_post)
        .add_server_post(server_post)
    }

    before do
      allow(local_post).to receive(:==) {|other| other.equal? server_post }
    end

    it "has no changes" do
      expect(subject).not_to have_changes
      expect(subject.changes).to eq []
    end
  end

  context "a changeset with an updated post" do
    let(:draft_post) { double(:draft_post) }
    let(:local_post) { double(:local_post, id: 1) }
    let(:server_post) { double(:server_post, id: 1) }

    subject {
      Pressy::RemoteChangeset.new
        .add_local_post(draft_post, local_post)
        .add_server_post(server_post)
    }

    before do
      allow(local_post).to receive(:==) { |other| other != server_post }
    end

    it "has an updated post" do
      expect(subject).to have_changes
      expect(subject.changes).to eq [
        Pressy::RemoteChangeset::UpdatedPost.new(draft_post, local_post)
      ]
    end
  end

  describe "change types" do
    let(:client) { double(:client) }
    let(:store) { double(:store) }

    describe Pressy::RemoteChangeset::AddedPost do
      let(:draft_post) { double(:draft_post) }
      let(:new_post) { double(:new_post) }
      let(:saved_post) { double(:saved_post) }
      let(:rendered_saved_post) { double(:rendered_saved_post) }

      subject { Pressy::RemoteChangeset::AddedPost.new(draft_post, new_post) }

      it "has type 'add'" do
        expect(subject.type).to be :add
      end

      it "creates the post and writes the updated version to a store" do
        expect(client).to receive(:create_post).with(new_post) { saved_post }
        expect(Pressy::PostRenderer).to receive(:render).with(saved_post) { rendered_saved_post }
        expect(store).to receive(:write).with(rendered_saved_post)
        subject.execute(store, client)
      end
    end

    describe Pressy::RemoteChangeset::UpdatedPost do
      let(:draft_post) { double(:draft_post) }
      let(:post) { double(:post) }
      let(:saved_post) { double(:saved_post) }
      let(:rendered_saved_post) { double(:rendered_saved_post) }

      subject { Pressy::RemoteChangeset::UpdatedPost.new(draft_post, post) }

      it "has type 'update'" do
        expect(subject.type).to be :update
      end

      it "edits the post and writes the updated version to a store" do
        expect(client).to receive(:edit_post).with(post) { saved_post }
        expect(Pressy::PostRenderer).to receive(:render).with(saved_post) { rendered_saved_post }
        expect(store).to receive(:write).with(rendered_saved_post)
        subject.execute(store, client)
      end
    end
  end
end
