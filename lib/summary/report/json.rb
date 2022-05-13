# frozen_string_literal: true

module Summary
  class Report
    class Json
      def initialize(report)
        @report = report
        @type = :json
        @extension = :json
      end

      def perform
        @report.create(content, @type, @extension)
      end

      private

      def content
        {
          identifier: @report.identifier,
          data: @report.data
        }.to_json
      end
    end
  end
end
