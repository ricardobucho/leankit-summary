# frozen_string_literal: true

module Summary
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

    PR_STATUS = {
      open: { style: 'success' },
      closed: { style: 'danger' },
      merged: { style: 'dark' },
      draft: { style: 'muted' }
    }.freeze

    def initialize
      @headers = {}
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

    def logger
      @logger ||= Summary::Logger.instance
    end

    def performed?
      @performed == true
    end

    def data
      perform unless performed?

      @data
    end

    def filename(type, extension)
      ending = type == extension ? extension : "#{type}.#{extension}"
      "#{REPORTS_DIRECTORY}/#{@identifier}.#{ending}"
    end

    def template(type)
      File.read("#{TEMPLATES_DIRECTORY}/#{type}/report.erb")
    end

    def create(content, type, extension)
      File.open(filename(type, extension), 'w+') { |file| file.write(content) }
      logger.success(">> Report file (#{type}) `#{filename(type, extension)}` has been generated.")
    end

    def create_json_report
      Summary::Report::Json.new(self).perform
    end

    def create_legacy_report
      Summary::Report::Legacy.new(self).perform
    end

    def create_evolved_report
      Summary::Report::Evolved.new(self).perform
    end

    private

    def create_basic_report
      @data[:board] ||= Leankit::Api.board
      @data[:lanes] ||= create_lanes_array(@data[:board])
    end

    def create_lanes_array(board)
      lanes = Leankit::Api.lanes(board)
      threads = []

      logger.group_start("Processing lanes: #{lanes.pluck(:name).join(', ')}")

      lanes.each { |lane| threads << Thread.new { create_lane_hash(lane) } }

      logger.group_end

      threads.map { |thread| thread.join && thread.value }
    end

    def create_lane_hash(lane)
      {
        id: lane[:id],
        name: lane[:name],
        cards: create_cards_array(lane)
      }
    end

    def create_cards_array(lane)
      Leankit::Api.cards(lane)
        .map { |card| create_log_entry(card) }
        .map { |card| create_hash(card, :card) }
        .sort_by { |hash| hash[:weeks_stale] }
        .reverse
    end

    def create_card_hash(card)
      {
        id: card[:id],
        header: header(card),
        leankit_url: "#{Config.get(:api_base_url)}/card/#{card[:id]}",
        title: CGI.escapeHTML(card[:title]),
        assignees: card[:assignedUsers].pluck(:fullName).join(', '),
        tasks: create_tasks_array(card),
        weeks_stale: weeks_stale(card),
        pull_request: pull_request(card)
      }
    end

    def create_tasks_array(card)
      return [] unless Config.get(:include_task_cards).presence

      Leankit::Api.tasks(card)
        .map { |task| create_log_entry(task) }
        .map { |task| create_hash(task, :task) }
        .sort_by { |hash| [hash[:status][:order], hash[:weeks_stale], hash[:movedOn]] }
        .reverse
    end

    def create_task_hash(task)
      {
        id: task[:id],
        header: header(task),
        leankit_url: "#{Config.get(:api_base_url)}/card/#{task[:id]}",
        title: task[:title],
        assignees: task[:assignedUsers].pluck(:fullName).join(', '),
        status: task_status(task),
        weeks_stale: task_weeks_stale(task),
        pull_request: pull_request(task)
      }
    end

    def create_log_entry(item)
      logger.item_start(item[:id], header(item))
      item
    end

    def create_hash(item, type = :card)
      send("create_#{type}_hash", item).tap do |hash|
        logger.item_end(hash[:id])
      end
    end

    def header(card)
      @headers[card[:id]] ||= "#{card[:customId][:prefix]}#{card[:customId][:value]}"
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

    def pull_request(card)
      return unless Config.get(:include_pull_requests).presence

      response = Github::Api.pull_request(header(card))

      pull_request =
        response[:nodes].reject do |pr|
          pr[:state] == 'CLOSED' && pr[:closed]
        end.first

      return pull_request_hash(pull_request) if
        response.is_a?(Hash) &&
        response[:issueCount].positive?

      nil
    end

    def pull_request_hash(pull_request)
      return {} if pull_request.blank?

      {
        number: pull_request[:number],
        url: pull_request[:url],
        closed: pull_request[:closed],
        draft: pull_request[:isDraft],
        state: pull_request[:state],
        status: pull_request_status(pull_request)
      }
    end

    def pull_request_status(pull_request)
      return PR_STATUS[:merged] if pull_request[:state] == 'MERGED'
      return PR_STATUS[:closed] if pull_request[:state] == 'CLOSED' && pull_request[:closed]
      return PR_STATUS[:draft] if pull_request[:isDraft]

      PR_STATUS[:open]
    end
  end
end
