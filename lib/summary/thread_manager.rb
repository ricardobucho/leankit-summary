# frozen_string_literal: true

module Summary
  class ThreadManager
    attr_writer :before_perform, :after_perform

    class << self
      def perform(iterables, &block)
        new.perform(iterables, &block)
      end
    end

    def initialize
      @threads = []
      @before_perform = -> {}
      @after_perform = -> {}
    end

    def perform(iterables, &block)
      @before_perform.call

      iterables.each do |iterable|
        @threads << Thread.new do
          block.call(iterable)
        end
      end

      @after_perform.call

      @threads.map { |thread| thread.join && thread.value }
    end
  end
end
