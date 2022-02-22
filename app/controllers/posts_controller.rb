require 'dry/validation'
require 'dry/monads'
require 'posts_repository'

class PostsController < ApplicationController
  include Dry::Monads[:result, :do]

  def create
    case PostsRepository.create(title: params[:title], rating: params[:rating])
    in Success(post) then render json: post, status: :ok
    in Failure(ActiveRecord::ActiveRecordError) then internal_server_error(code: '002')
    in Failure(StandardError) then internal_server_error(code: '001')
    in Failure(Dry::Validation::Result => result) then unprocessable_entity(result: result)
    else internal_server_error(code: '003')
    end
  end

  def index
    case PostsRepository.find_all
    in Success(posts) then render json: posts, status: :ok
    in Failure(ActiveRecord::ActiveRecordError) then internal_server_error(code: '002')
    in Failure(StandardError) then internal_server_error(code: '001')
    else internal_server_error(code: '003')
    end
  end

  def show
    case PostsRepository.find_by_id(id: params[:id])
    in Success(post) then render json: post, status: :ok
    in Failure(ActiveRecord::RecordNotFound) then not_found
    in Failure(ActiveRecord::ActiveRecordError) then internal_server_error(code: '002')
    in Failure(StandardError) then internal_server_error(code: '001')
    else internal_server_error(code: '003')
    end
  end

  private

  def internal_server_error(code:)
    render json: { message: 'Internal server error', code: code }, status: :internal_server_error
  end

  def unprocessable_entity(result:)
    render json: { message: 'Unprocessable entity', errors: result.errors.to_h }, status: :unprocessable_entity
  end

  def not_found
    render json: { message: 'Not found' }, status: :not_found
  end
end
