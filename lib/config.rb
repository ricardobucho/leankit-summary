# frozen_string_literal: true

class Config
  class << self
    def set
      @configuration = {
        api_base_url: nil,
        api_token: nil,
        board_id: nil,
        lanes: [],
        include_task_cards: true
      }

      yield(@configuration)
    end

    def get(key)
      @configuration[key]
    end

    def preflight
      @configuration.each do |(key, value)|
        if value.blank?
          puts "", "!! There is no configured value for `#{key}`.", ""
          exit
        end
      end
    end
  end
end
