  # helper methods for JSON responses in tests
  def auth_headers(user)
    token = JsonWebToken.encode(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end

  def json
    JSON.parse(response.body)
  end