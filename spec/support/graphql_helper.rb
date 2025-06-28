module GraphqlHelper
  # Helper method to make GraphQL requests in tests
  def graphql_request(query, variables: {}, headers: {})
    post "/graphql",
      params: { query: query, variables: variables }.to_json,
      headers: headers.merge({ "Content-Type" => "application/json" })
  end
end
