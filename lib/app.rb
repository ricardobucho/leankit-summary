# frozen_string_literal: true

class App
  def perform
    @report = Leankit::Report.new

    @report.create_json_report
    @report.create_html_report
  end
end
