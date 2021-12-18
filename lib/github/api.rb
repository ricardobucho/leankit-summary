# frozen_string_literal: true

module Github
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
        get('search/issues', {
          q: "#{title} in:title type:pr repo:#{Config.get(:github_repository)}"
        })
      )
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
      return value unless
        value.is_a?(HTTParty::Response) ||
        value.is_a?(Hash)

      value.deep_symbolize_keys
    end

    def get(path, query = {})
      return unless preflight?

      HTTParty.get(
        "#{Config.get(:github_api_base_url)}/#{path}",
        headers: {
          Accept: 'application/vnd.github.v3+json',
          Authorization: "Bearer #{Config.get(:github_token)}"
        },
        query: query
      )
    end
  end
end
