# frozen_string_literal: true

module Summary
  class Report
    class Html
      def initialize(report)
        @report = report
      end

      def perform
        @report.create(parsed, :html)
        Launchy.open(@report.filename(:html))
        exec "open ./#{@report.class::REPORTS_DIRECTORY}"
      end

      private

      def parsed
        ERB.new(@report.template(:html)).result(content)
      end

      def content
        OpenStruct.new(
          {
            identifier: @report.identifier,
            timestamp: @report.timestamp,
            date: @report.timestamp.strftime('%B %-d, %Y'),
            datetime: @report.timestamp.strftime('%B %-d, %Y @ %H:%M:%S'),
            **@report.data
          }
        ).instance_eval { binding }
      end
    end
  end
end
