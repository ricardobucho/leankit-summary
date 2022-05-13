# frozen_string_literal: true

module Summary
  class Report
    class Evolved
      def initialize(report)
        @report = report
        @type = :evolved
        @extension = :html
      end

      def perform
        @report.create(parsed, @type, @extension)
        Launchy.open(@report.filename(@type, @extension))
        `open ./#{@report.class::REPORTS_DIRECTORY}`
      end

      private

      def parsed
        ERB.new(@report.template(@type)).result(content)
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
