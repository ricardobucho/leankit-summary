# frozen_string_literal: true

module Summary
  class Logger
    include Singleton

    def initialize
      @pastel = Pastel.new
      @spinners = nil
      @items = {}
    end

    def group_start(message)
      group_end if @spinners.present?

      @spinners = TTY::Spinner::Multi.new(@pastel.blue.bold(message))
      @spinners.auto_spin
    end

    def group_end
      @items.each(&:error)
      @items = {}

      @spinners.success
    end

    def item_start(id, message)
      @items[id] = @spinners.register("[:spinner] #{message}")
      @items[id].auto_spin
    end

    def item_end(id)
      @items[id].success
      @items.delete(id)
    end

    def success(message)
      puts @pastel.green(message)
    end
  end
end
