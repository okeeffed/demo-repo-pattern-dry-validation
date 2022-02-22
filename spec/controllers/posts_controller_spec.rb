require 'rails_helper'
require 'dry/monads'
require 'post_contract'
require 'posts_repository'

Dry::Validation.load_extensions(:monads)

RSpec.describe PostsController, type: :controller do
  include Dry::Monads[:result]

  describe 'GET #index' do
    context 'successful responses' do
      it 'returns empty successful array when there are no posts' do
        stubbed_response = []
        posts_respository_klass = class_double(PostsRepository, find_all: Success([stubbed_response])).as_stubbed_const

        expect(posts_respository_klass).to receive(:find_all)

        get :index
        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to eq(JSON.parse(stubbed_response.to_json))
      end

      it 'returns correct array when there are posts' do
        posts = [{
          id: 1,
          title: 'Cool post',
          rating: 'Good'
        }]
        posts_respository_klass = class_double(PostsRepository, find_all: Success([posts])).as_stubbed_const

        expect(posts_respository_klass).to receive(:find_all)

        get :index
        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to eq(JSON.parse(posts.to_json))
      end
    end

    context 'unsuccessful responses' do
      it 'returns 500 when there is an ActiveRecord::ActiveRecordError' do
        res = { message: 'Internal server error', code: '002' }
        posts_respository_klass = class_double(PostsRepository,
                                               find_all: Failure(ActiveRecord::ActiveRecordError.new)).as_stubbed_const

        expect(posts_respository_klass).to receive(:find_all)

        get :index
        expect(response).to have_http_status(:internal_server_error)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end

      it 'returns 500 when there is a StandardError' do
        res = { message: 'Internal server error', code: '001' }
        posts_respository_klass = class_double(PostsRepository, find_all: Failure(StandardError.new)).as_stubbed_const

        expect(posts_respository_klass).to receive(:find_all)

        get :index
        expect(response).to have_http_status(:internal_server_error)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end
    end
  end

  describe 'GET #show' do
    context 'successful responses' do
      it 'returns correct array when there is a post with the expected ID' do
        stubbed_response = {
          id: 1,
          title: 'Cool post',
          rating: 'Good'
        }
        posts_respository_klass = class_double(PostsRepository, find_by_id: Success(stubbed_response)).as_stubbed_const

        expect(posts_respository_klass).to receive(:find_by_id).with(id: '1')

        get :show, params: { id: '1' }
        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to eq(JSON.parse(stubbed_response.to_json))
      end
    end

    context 'unsuccessful responses' do
      it 'returns 500 when there is an ActiveRecord::ActiveRecordError' do
        res = { message: 'Internal server error', code: '002' }
        posts_respository_klass = class_double(PostsRepository,
                                               find_by_id: Failure(ActiveRecord::ActiveRecordError.new)).as_stubbed_const

        expect(posts_respository_klass).to receive(:find_by_id).with(id: '1')

        get :show, params: { id: '1' }
        expect(response).to have_http_status(:internal_server_error)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end

      it 'returns 500 when there is a StandardError' do
        res = { message: 'Internal server error', code: '001' }
        posts_respository_klass = class_double(PostsRepository, find_by_id: Failure(StandardError.new)).as_stubbed_const

        expect(posts_respository_klass).to receive(:find_by_id).with(id: '1')

        get :show, params: { id: '1' }
        expect(response).to have_http_status(:internal_server_error)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end

      it 'returns 404 when there is no matching post' do
        res = { message: 'Not found' }
        posts_respository_klass = class_double(PostsRepository).as_stubbed_const
        allow(posts_respository_klass).to receive(:find_by_id).and_return(Failure(ActiveRecord::RecordNotFound.new))

        expect(posts_respository_klass).to receive(:find_by_id).with(id: '1')

        get :show, params: { id: '1' }
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end
    end
  end

  describe 'POST #create' do
    context 'successful responses' do
      it 'returns 200 and created post when the post is valid' do
        stubbed_response = { id: 1, title: 'Title', rating: 'Good' }
        posts_respository_klass = class_double(PostsRepository, create: Success(stubbed_response)).as_stubbed_const

        expect(posts_respository_klass).to receive(:create).with(title: 'Title', rating: 'Good')

        post :create, params: { title: 'Title', rating: 'Good' }, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq(JSON.parse(stubbed_response.to_json))
      end
    end

    context 'invalid params' do
      it 'returns 422 when there are invalid params for title' do
        res = { message: 'Unprocessable entity', errors: { title: ['must be a string'] } }
        posts_respository_klass = class_double(PostsRepository).as_stubbed_const

        expect(posts_respository_klass).to_not receive(:create)

        post :create, params: { title: 100, rating: 'Good' }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end

      it 'returns 422 when there are invalid params for rating' do
        res = { message: 'Unprocessable entity', errors: { rating: ['must be a string'] } }
        posts_respository_klass = class_double(PostsRepository).as_stubbed_const

        expect(posts_respository_klass).to_not receive(:create)

        post :create, params: { title: 'Title', rating: 100 }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end
    end

    context 'unsuccessful responses' do
      it 'returns 500 when there is an ActiveRecord::ActiveRecordError' do
        res = { message: 'Internal server error', code: '002' }
        posts_respository_klass = class_double(PostsRepository,
                                               create: Failure(ActiveRecord::ActiveRecordError.new)).as_stubbed_const

        expect(posts_respository_klass).to receive(:create).with(title: 'Title', rating: 'Good')

        post :create, params: { title: 'Title', rating: 'Good' }, as: :json
        expect(response).to have_http_status(:internal_server_error)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end

      it 'returns 500 when there is a StandardError' do
        res = { message: 'Internal server error', code: '001' }
        posts_respository_klass = class_double(PostsRepository, create: Failure(StandardError.new)).as_stubbed_const

        expect(posts_respository_klass).to receive(:create).with(title: 'Title', rating: 'Good')

        post :create, params: { title: 'Title', rating: 'Good' }, as: :json
        expect(response).to have_http_status(:internal_server_error)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end

      it 'returns 500 when there is an unexpected state' do
        res = { message: 'Internal server error', code: '003' }
        posts_respository_klass = class_double(PostsRepository, create: Failure(Exception.new)).as_stubbed_const

        expect(posts_respository_klass).to receive(:create).with(title: 'Title', rating: 'Good')

        post :create, params: { title: 'Title', rating: 'Good' }, as: :json
        expect(response).to have_http_status(:internal_server_error)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end
    end
  end
end
