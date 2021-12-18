# frozen_string_literal: true

module Github
  # GraphQL Explorer
  # https://docs.github.com/en/graphql/overview/explorer
  class Api
    include Singleton

    class << self
      def respond_to_missing?(method_name, *)
        instance.respond_to?(method_name)
      end

      def method_missing(*args)
        instance.send(*args)
      end
    end

    def pull_request(title)
      format(
        graphql(
          <<-QUERY.squish
            {
              search(query: "#{title} is:pr in:title repo:#{Config.get(:github_repository)}", type: ISSUE, first: 3) {
                issueCount
                nodes {
                  ... on PullRequest {
                    id
                    url
                    number
                    state
                    title
                    updatedAt
                    closed
                    isDraft
                  }
                }
              }
            }
          QUERY
        )
      )[:data][:search]
    end

    private

    def preflight?
      return false if [
        Config.get(:github_api_base_url),
        Config.get(:github_token),
        Config.get(:github_repository)
      ].any?(nil)

      true
    end

    def format(value)
      return JSON.parse(value, symbolize_names: true) if
        value.is_a?(String)

      value
    end

    def graphql(query = '{}')
      return unless preflight?

      HTTParty.post(
        "#{Config.get(:github_api_base_url)}/graphql",
        headers: {
          Accept: 'application/vnd.github.v3+json',
          Authorization: "Bearer #{Config.get(:github_token)}"
        },
        body: { query: query, variables: {} }.to_json
      ).body
    end
  end
end
