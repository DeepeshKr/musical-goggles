class CurrentUserController < ApplicationController
  before_action :authenticate_user!
  def index
    user_id = decode_auth_token(request.headers['Authorization'])
    user = User.find(user_id)
    # render json: user
    render json: user, each_serializer: UserSerializer
  end

  private

  def decode_auth_token(token)
    JWT.decode(token.split(' ').last, 'DEVISE_JWT_SECRET_KEY_IN+ENV', true, algorithm: 'HS256')[0]['sub']
  rescue JWT::DecodeError
    nil
  end
end