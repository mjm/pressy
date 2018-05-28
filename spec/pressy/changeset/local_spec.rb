require 'spec_helper'

RSpec.describe Pressy::LocalChangeset do
  context "an empty changeset" do
    subject { Pressy::LocalChangeset.new }

    it "has no changes" do
      expect(subject).not_to have_changes
      expect(subject.changes).to be_empty
    end
  end

  context "a changeset with one new post" do
    let(:new_post) { double(:post, digest: "abc") }

    subject do
      changes = Pressy::LocalChangeset.new
      changes.add_server_post(123, new_post)
    end

    it "has an added post" do
      expect(subject).to have_changes
      expect(subject.changes).to eq [
        Pressy::LocalChangeset::AddedPost.new(123, new_post)
      ]
    end
  end

  context "a changeset with one deleted post" do
    let(:deleted_post) { double(:post, digest: "abc") }
    subject { Pressy::LocalChangeset.new.add_local_post(123, deleted_post) }

    it "has a deleted post" do
      expect(subject).to have_changes
      expect(subject.changes).to eq [
        Pressy::LocalChangeset::DeletedPost.new(123, deleted_post)
      ]
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
      expect(subject.changes).to eq []
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

    it "has an updated post" do
      expect(subject).to have_changes
      expect(subject.changes).to eq [
        Pressy::LocalChangeset::UpdatedPost.new(123, local_post, server_post)
      ]
    end
  end

  context "a changeset with a draft post" do
    let(:draft_post) { double(:draft_post, digest: "abc") }

    subject {
      Pressy::LocalChangeset.new
        .add_local_post(nil, draft_post)
    }

    it "has no changes" do
      expect(subject).not_to have_changes
      expect(subject.changes).to eq []
    end
  end

  it "updates the diff results when posts are added" do
    subject = Pressy::LocalChangeset.new
    expect(subject.changes).to be_empty
    subject.add_server_post(123, double(:post, digest: "abc"))
    expect(subject.changes).not_to be_empty
    subject.add_local_post(123, double(:post, digest: "abc"))
    expect(subject.changes).to be_empty
  end

  describe "change types" do
    let(:store) { double(:store) }

    describe Pressy::LocalChangeset::AddedPost do
      let(:post) { double(:rendered_post) }
      subject { Pressy::LocalChangeset::AddedPost.new(123, post) }

      it "has type 'add'" do
        expect(subject.type).to be :add
      end

      it "writes the post to a store" do
        expect(store).to receive(:write).with(123, post)
        subject.execute(store)
      end
    end

    describe Pressy::LocalChangeset::UpdatedPost do
      let(:existing_post) { double(:existing_post, path: "foo/bar.md") }
      let(:updated_post) { double(:updated_post, path: "foo/bar.md") }
      subject { Pressy::LocalChangeset::UpdatedPost.new(123, existing_post, updated_post) }

      it "has type 'update'" do
        expect(subject.type).to be :update
      end

      context "when the filenames of the posts match" do
        it "writes the post to a store" do
          expect(store).to receive(:write).with(123, updated_post)
          subject.execute(store)
        end
      end

      context "when the filenames of the posts no longer match" do
        let(:updated_post) { double(:updated_post, path: "foo/baz.md") }

        it "write the post to a store and deletes the old post" do
          # order matters because delete will remove the digest
          expect(store).to receive(:delete).with(123, existing_post).ordered
          expect(store).to receive(:write).with(123, updated_post).ordered

          subject.execute(store)
        end
      end
    end

    describe Pressy::LocalChangeset::DeletedPost do
      let(:post) { double(:rendered_post) }
      subject { Pressy::LocalChangeset::DeletedPost.new(123, post) }

      it "has type 'delete'" do
        expect(subject.type).to be :delete
      end

      it "deletes the post from a store" do
        expect(store).to receive(:delete).with(123, post)
        subject.execute(store)
      end
    end
  end
end
