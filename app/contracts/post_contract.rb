require 'dry/validation'

class PostContract < Dry::Validation::Contract
  params do
    required(:title).filled(:string)
    required(:rating).filled(:string)
  end
end
