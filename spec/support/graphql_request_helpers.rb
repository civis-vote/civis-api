module GraphqlRequestHelpers
  def gql_post(query, variables: {}, user: nil, token: nil)
    headers = {}
    headers['Authorization'] = token if token
    headers['Authorization'] ||= user.find_or_generate_api_key.access_token if user
    post '/graphql', params: { query: query, variables: variables }, as: :json, headers: headers
    JSON.parse(response.body)
  end

  def gql_data(result, key)
    result.dig('data', key)
  end

  def gql_errors(result)
    result['errors']
  end
end

module GraphqlSchemaHelpers
  def gql_execute(query, variables: {}, context: {})
    CivisApiSchema.execute(query, variables: variables, context: context)
  end

  def gql_data(result, key)
    result.dig('data', key)
  end

  def gql_errors(result)
    result['errors']
  end
end
