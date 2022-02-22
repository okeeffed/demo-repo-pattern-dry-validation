class PostsRepository
  class << self
    def create(title:, rating:)
      post = Post.new(title: title, rating: rating)
      post.save!

      # `save!`` will raise if there is an error, so we assume here
      # that we were successful and return the post to follow RESTful conventions.
      # @see https://restfulapi.net/http-status-200-ok/
      post
    end

    def find_all
      Post.all
    end

    def find_by_id(id:)
      Post.find_by(id: id)
    end

    def destroy(post:)
      post.destroy
    end
  end
end
