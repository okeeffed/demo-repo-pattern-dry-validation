require 'dry/monads'

class PostsRepository
  class << self
    include Dry::Monads[:result]

    def create(title:, rating:)
      post = Post.new(title: title, rating: rating)
      post.save!

      # `save!`` will raise if there is an error, so we assume here
      # that we were successful and return the post to follow RESTful conventions.
      # @see https://restfulapi.net/http-status-200-ok/
      Success(post)
    rescue ActiveRecord::ActiveRecordError => e
      Failure(e)
    rescue StandardError => e
      Failure(e)
    end

    def find_all
      posts = Post.all
      Success(posts)
    rescue ActiveRecord::ActiveRecordError => e
      Failure(e)
    rescue StandardError => e
      Failure(e)
    end

    def find_by_id(id:)
      post = Post.find_by!(id: id)
      Success(post)
    rescue ActiveRecord::RecordNotFound => e
      Failure(e)
    rescue ActiveRecord::ActiveRecordError => e
      Failure(e)
    rescue StandardError => e
      Failure(e)
    end
  end
end
