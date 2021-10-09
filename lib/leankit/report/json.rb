# frozen_string_literal: true

module Leankit
  class Report
    class Json
      def initialize(report)
        @report = report
      end

      def perform
        @report.create(content, :json)
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
