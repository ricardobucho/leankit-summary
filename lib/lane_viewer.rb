# frozen_string_literal: true

class LaneViewer
  def perform
    separator

    puts title

    separator

    board[:lanes].pluck(:id, :name).map do |(id, name)|
      puts "-> Lane ID: #{id}\t| Name: #{name}"
    end

    separator

    puts 'Pick some and add them to the LK_LANES env.'
    puts 'Below is an example with all of them.'

    separator

    puts "LK_LANES=#{board[:lanes].pluck(:id).flatten.join('; ')}"

    separator
  end

  private

  def board
    @board ||= Leankit::Api.board
  end

  def title
    "Showing all available lanes in order for board #{board[:title]}"
  end

  def separator
    puts '-' * title.length
  end
end
