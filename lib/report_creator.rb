# frozen_string_literal: true

class ReportCreator
  def initialize
    @report = Summary::Report.new
  end

  def perform
    @report.create_json_report
    @report.create_html_report
  end
end
