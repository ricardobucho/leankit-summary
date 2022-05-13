# frozen_string_literal: true

class ReportCreator
  def initialize
    @report = Summary::Report.new
  end

  def perform
    @report.create_json_report if Config.get(:use_json_report)
    @report.create_legacy_report if Config.get(:use_legacy_report)
    @report.create_evolved_report if Config.get(:use_evolved_report)
  end
end
