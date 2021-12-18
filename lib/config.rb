# frozen_string_literal: true

class Config
  class << self
    def set
      @configuration = {
        api_base_url: nil,
        api_token: nil,
        board_id: nil,
        lanes: [],
        github_api_base_url: nil,
        github_token: nil,
        github_repository: nil,
        include_task_cards: true
      }

      yield(@configuration)
    end

    def get(key)
      @configuration[key]
    end

    def preflight
      @configuration.each do |(key, value)|
        if value.to_s.squish.blank?
          puts '', "!! There is no configured value for `#{key}`.", ''
          exit
        end
      end
    end
  end
end
