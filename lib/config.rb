# frozen_string_literal: true

class Config
  class << self
    def set
      @configuration = {
        api_base_url: nil,
        api_token: nil,
        board_id: nil,
        lanes: []
      }

      yield(@configuration)
    end

    def get(key)
      @configuration[key]
    end
  end
end
