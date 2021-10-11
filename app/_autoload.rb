# frozen_string_literal: true

require 'active_support/all'
require 'bundler/setup'

Bundler.require
Dotenv.load

loader = Zeitwerk::Loader.new
loader.push_dir('lib')
loader.setup

Config.set do |config|
  config[:api_base_url] = ENV['LK_API_BASE_URL'].squish
  config[:api_token] = ENV['LK_API_TOKEN'].squish
  config[:board_id] = ENV['LK_BOARD_ID'].squish
  config[:lanes] = ENV['LK_LANES'].split(';').map(&:squish)
  config[:include_task_cards] = ENV['INCLUDE_TASK_CARDS'].to_s.downcase == 'true'
end

Config.preflight
