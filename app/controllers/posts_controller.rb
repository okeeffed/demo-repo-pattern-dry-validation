require 'posts_repository'

class PostsController < ApplicationController
  def create
    post = PostsRepository.create(title: params[:title], rating: params[:rating])

    render json: post, status: :ok
  rescue ActiveRecord::ActiveRecordError
    render json: { message: 'Internal server error' }, status: :internal_server_error
  rescue StandardError
    render json: { message: 'Internal server error' }, status: :internal_server_error
  end

  def index
    posts = PostsRepository.find_all
    render json: posts, status: :ok
  rescue ActiveRecord::ActiveRecordError
    render json: { message: 'Internal server error' }, status: :internal_server_error
  rescue StandardError
    render json: { message: 'Internal server error' }, status: :internal_server_error
  end

  def show
    post = PostsRepository.find_by_id(id: params[:id])
    render json: post, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Not found' }, status: :not_found
  rescue ActiveRecord::ActiveRecordError
    render json: { message: 'Internal server error' }, status: :internal_server_error
  rescue StandardError
    render json: { message: 'Internal server error' }, status: :internal_server_error
  end
end
