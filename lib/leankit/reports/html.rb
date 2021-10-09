# frozen_string_literal: true

module Leankit
  module Reports
    class Html
      def initialize(report)
        @report = report
      end

      def perform
        @report.create(parsed, :html)
        Launchy.open(@report.filename(:html))
      end

      private

      def parsed
        ERB.new(@report.template(:html)).result(content)
      end

      def content
        OpenStruct.new(
          {
            identifier: @report.identifier,
            **@report.data
          }
        ).instance_eval { binding }
      end
    end
  end
end
