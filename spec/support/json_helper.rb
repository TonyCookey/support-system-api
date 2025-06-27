  def auth_headers(user)
    {
      "Authorization" => "Bearer #{JsonWebToken.encode(user_id: user.id)}",
      "Content-Type" => "application/json"
    }
  end