# frozen_string_literal: true

module Leankit
  class Report
    attr_reader :identifier, :performed

    REPORTS_DIRECTORY = 'reports'
    TEMPLATES_DIRECTORY = 'templates'

    # @report = {
    #   performed: false,
    #   lanes: [
    #     {
    #       name: '...',
    #       cards: [
    #         {
    #           name: '...',
    #           tasks: [
    #           ]
    #         }
    #       ]
    #     }
    #   ]
    # }

    def initialize
      @identifier = DateTime.current.to_s
      @performed = false

      @data = {
        lanes: []
      }
    end

    def perform
      return self if performed?

      create_basic_report

      @performed = true

      self
    end

    def performed?
      @performed == true
    end

    def data
      perform unless performed?

      @data
    end

    def filename(type)
      "#{REPORTS_DIRECTORY}/#{@identifier}.#{type}"
    end

    def template(type)
      File.read("#{TEMPLATES_DIRECTORY}/#{type}/report.erb")
    end

    def create(content, type)
      File.open(filename(type), 'w+') { |file| file.write(content) }
    end

    def create_json_report
      Leankit::Reports::Json.new(self).perform
    end

    def create_html_report
      Leankit::Reports::Html.new(self).perform
    end

    private

    def create_basic_report
      lanes = Leankit::Api.lanes

      lanes.map do |lane|
        @data[:lanes] << {
          name: lane[:name],
          cards: create_cards_array(lane)
        }
      end
    end

    def create_cards_array(lane)
      Leankit::Api.cards(lane).map { |card| create_card_hash(card) }
    end

    def create_card_hash(card)
      {
        id: card[:id],
        header: "#{card[:customId][:prefix]}#{card[:customId][:value]}",
        title: card[:title],
        assignees: card[:assignedUsers].pluck(:fullName).join(', '),
        tasks: create_tasks_array(card)
      }
    end

    def create_tasks_array(card)
      []
    end
  end
end
