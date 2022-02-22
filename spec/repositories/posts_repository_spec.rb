require 'rails_helper'
require 'posts_repository'
require 'pry'

RSpec.describe PostsRepository do
  describe '#create' do
    context 'valid parameters' do
      let(:subject) { build(:post) }

      it 'returns a post' do
        result = PostsRepository.create(title: subject.title, rating: subject.rating)
        expect(result.success?).to eq(true)

        post = result.value!
        expect(post).to be_a(Post)
        expect(post.title).to eq(subject.title)
        expect(post.rating).to eq(subject.rating)
      end
    end

    context 'invalid parameters' do
      let(:subject) { build(:post, title: nil) }

      it 'returns an active record error when the post is invalid' do
        result = PostsRepository.create(title: subject.title, rating: subject.rating)
        expect(result.failure?).to eq(true)

        expect(result.failure).to be_a(Dry::Validation::Result)
      end
    end
  end
end
