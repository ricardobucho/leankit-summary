# frozen_string_literal: true

class Config
  class << self
    def set
      @configuration = {
        api_base_url: nil,
        api_token: nil,
        board_id: nil,
        lanes: [],
        development_lane: nil,
        github_api_base_url: nil,
        github_token: nil,
        github_repository: nil,
        include_task_cards: true,
        use_json_report: false,
        use_legacy_report: false,
        use_evolved_report: true
      }

      yield(@configuration)
    end

    def get(key)
      @configuration[key]
    end

    def preflight
      all_keys_present?
      at_least_one_report_enabled?
    end

    private

    def all_keys_present?
      @configuration.each do |(key, value)|
        if value.to_s.squish.blank?
          puts '', "!! There is no configured value for `#{key}`.", ''
          exit
        end
      end
    end

    def at_least_one_report_enabled?
      if @configuration.values_at(
        :use_json_report,
        :use_legacy_report,
        :use_evolved_report
      ).all?(false)
        puts '', '!! Enable at least one report type.', ''
        exit
      end
    end
  end
end
