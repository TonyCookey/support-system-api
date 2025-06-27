module GraphqlHelper
  def graphql_request(query, variables: {}, headers: {})
    post "/graphql",
      params: { query: query, variables: variables }.to_json,
      headers: headers.merge({ "Content-Type" => "application/json" })
  end
end
