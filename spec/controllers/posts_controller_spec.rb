require 'rails_helper'
require 'posts_repository'

RSpec.describe PostsController, type: :controller do
  describe 'GET #index' do
    context 'successful responses' do
      it 'returns empty successful array when there are no posts' do
        stubbed_response = []
        posts_respository_klass = class_double(PostsRepository, find_all: stubbed_response).as_stubbed_const

        expect(posts_respository_klass).to receive(:find_all)

        get :index
        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to eq(stubbed_response)
      end

      it 'returns correct array when there are posts' do
        stubbed_response = [{
          id: 1,
          title: 'Cool post',
          rating: 'Good'
        }]
        posts_respository_klass = class_double(PostsRepository, find_all: stubbed_response).as_stubbed_const

        expect(posts_respository_klass).to receive(:find_all)

        get :index
        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to eq(JSON.parse(stubbed_response.to_json))
      end
    end

    context 'unsuccessful responses' do
      it 'returns 500 when there is an ActiveRecord::ActiveRecordError' do
        res = { message: 'Internal server error' }
        posts_respository_klass = class_double(PostsRepository).as_stubbed_const
        allow(posts_respository_klass).to receive(:find_all).and_raise(ActiveRecord::ActiveRecordError)

        expect(posts_respository_klass).to receive(:find_all)

        get :index
        expect(response).to have_http_status(:internal_server_error)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end

      it 'returns 500 when there is a StandardError' do
        res = { message: 'Internal server error' }
        posts_respository_klass = class_double(PostsRepository).as_stubbed_const
        allow(posts_respository_klass).to receive(:find_all).and_raise(StandardError)

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
        posts_respository_klass = class_double(PostsRepository, find_by_id: stubbed_response).as_stubbed_const

        expect(posts_respository_klass).to receive(:find_by_id).with(id: '1')

        get :show, params: { id: '1' }
        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to eq(JSON.parse(stubbed_response.to_json))
      end
    end

    context 'unsuccessful responses' do
      it 'returns 500 when there is an ActiveRecord::ActiveRecordError' do
        res = { message: 'Internal server error' }
        posts_respository_klass = class_double(PostsRepository).as_stubbed_const
        allow(posts_respository_klass).to receive(:find_by_id).and_raise(ActiveRecord::ActiveRecordError)

        expect(posts_respository_klass).to receive(:find_by_id).with(id: '1')

        get :show, params: { id: '1' }
        expect(response).to have_http_status(:internal_server_error)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end

      it 'returns 500 when there is a StandardError' do
        res = { message: 'Internal server error' }
        posts_respository_klass = class_double(PostsRepository).as_stubbed_const
        allow(posts_respository_klass).to receive(:find_by_id).and_raise(StandardError)

        expect(posts_respository_klass).to receive(:find_by_id).with(id: '1')

        get :show, params: { id: '1' }
        expect(response).to have_http_status(:internal_server_error)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end

      it 'returns 404 when there is no matching post' do
        res = { message: 'Not found' }
        posts_respository_klass = class_double(PostsRepository).as_stubbed_const
        allow(posts_respository_klass).to receive(:find_by_id).and_raise(ActiveRecord::RecordNotFound)

        expect(posts_respository_klass).to receive(:find_by_id).with(id: '1')

        get :show, params: { id: '1' }
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to eq(JSON.parse(res.to_json))
      end
    end
  end

  describe 'POST #create' do
    # ... omitted
  end
end
