# frozen_string_literal: true

module Leankit
  class Report
    attr_reader :timestamp, :identifier, :performed

    REPORTS_DIRECTORY = 'reports'
    TEMPLATES_DIRECTORY = 'templates'

    STATUS_LABELS = {
      not_started: 'Not Started',
      started: 'Started',
      finished: 'Finished',
      unknown: 'Unknown'
    }.freeze

    STATUS = {
      not_started: { order: 4, label: STATUS_LABELS[:not_started], style: 'danger' },
      started: { order: 3, label: STATUS_LABELS[:started], style: 'info' },
      finished: { order: 2, label: STATUS_LABELS[:finished], style: 'success' },
      unknown: { order: 1, label: STATUS_LABELS[:unknown], style: 'warning' }
    }.freeze

    def initialize
      @timestamp = Time.now
      @identifier = @timestamp.strftime('%Y%m%dT%H%M%S')
      @performed = false
      @data = {}
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
      puts "Report file `#{filename(type)}` has been generated."
    end

    def create_json_report
      Leankit::Report::Json.new(self).perform
    end

    def create_html_report
      Leankit::Report::Html.new(self).perform
    end

    private

    def create_basic_report
      @data[:board] ||= Leankit::Api.board
      @data[:lanes] ||= create_lanes_array(@data[:board])
    end

    def create_lanes_array(board)
      Leankit::Api.lanes(board).map { |lane| create_lane_hash(lane) }
    end

    def create_lane_hash(lane)
      {
        id: lane[:id],
        name: lane[:name],
        cards: create_cards_array(lane)
      }
    end

    def create_cards_array(lane)
      Leankit::Api
        .cards(lane)
        .map { |card| create_card_hash(card) }
        .sort_by { |hash| hash[:weeks_stale] }
        .reverse
    end

    def create_card_hash(card)
      header = "#{card[:customId][:prefix]}#{card[:customId][:value]}"

      {
        id: card[:id],
        header: header,
        leankit_url: "#{Config.get(:api_base_url)}/card/#{card[:id]}",
        title: CGI::escapeHTML(card[:title]),
        assignees: card[:assignedUsers].pluck(:fullName).join(', '),
        tasks: create_tasks_array(card),
        weeks_stale: weeks_stale(card),
        pull_request: pull_request(header)
      }
    end

    def create_tasks_array(card)
      return [] unless Config.get(:include_task_cards).presence

      Leankit::Api.tasks(card)
        .map { |task| create_task_hash(task) }
        .sort_by { |hash| [hash[:status][:order], hash[:weeks_stale], hash[:movedOn]] }
        .reverse
    end

    def create_task_hash(task)
      header = "#{card[:customId][:prefix]}#{card[:customId][:value]}"

      {
        id: card[:id],
        header: header,
        leankit_url: "#{Config.get(:api_base_url)}/card/#{task[:id]}",
        title: task[:title],
        assignees: task[:assignedUsers].pluck(:fullName).join(', '),
        status: task_status(task),
        weeks_stale: task_weeks_stale(task),
        pull_request: pull_request(header)
      }
    end

    def weeks_stale(card)
      return unless card[:movedOn].present?

      now = Time.now
      last_moved = Time.parse(card[:movedOn])

      (now - last_moved).seconds.in_weeks.to_i
    end

    def task_status(task)
      return STATUS[:not_started] if task[:actualStart].nil?
      return STATUS[:started] if task[:actualStart].present? && !task[:isDone]
      return STATUS[:finished] if task[:actualStart].present? && task[:isDone]

      STATUS[:unknown]
    end

    def task_weeks_stale(task)
      task_status(task)[:label] == STATUS_LABELS[:started] ? weeks_stale(task) : '-'
    end

    def pull_request(header)
      request = Github::Api.pull_request(header)

      return pull_request_data(request[:items].first) if
        request.is_a?(Hash) &&
        request[:total_count].positive?

      nil
    end

    def pull_request_data(pull_request_item)
      return {} if pull_request_item.blank?

      {
        number: pull_request_item[:number],
        url: pull_request_item[:pull_request][:html_url],
        draft: pull_request_item[:draft],
        state: pull_request_item[:state]
      }
    end
  end
end
