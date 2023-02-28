module Helpers
  def auth_headers(user)
    token = user.generate_token
    { "Authorization": "Bearer #{token}" }
  end
end

