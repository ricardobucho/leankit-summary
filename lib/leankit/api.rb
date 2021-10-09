# frozen_string_literal: true

module Leankit
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

    def board
      @board ||= format(get("io/board/#{Config.get(:board_id)}"))
    end

    def lanes
      config_lanes = Config.get(:lanes)

      board[:lanes].select do |lane|
        lane[:id].in?(config_lanes) ||
          lane[:name].in?(config_lanes)
      end
    end

    def cards(lane)
      return [] unless lane.is_a?(Hash)

      @cards ||= {}
      @cards[lane[:id]] ||= format(get('io/card', { lanes: lane[:id] }))[:cards]
    end

    def tasks(card)
      {}
    end

    private

    def format(value)
      return value unless
        value.is_a?(HTTParty::Response) ||
        value.is_a?(Hash)

      value.deep_symbolize_keys
    end

    def get(path, query = {})
      HTTParty.get(
        "#{Config.get(:api_base_url)}/#{path}",
        headers: {
          Authorization: "Bearer #{Config.get(:api_token)}"
        },
        query: query
      )
    end
  end
end
