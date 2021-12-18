# frozen_string_literal: true

require 'bundler/setup'
require 'active_support/all'

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
  config[:github_api_base_url] = ENV['GH_API_BASE_URL'].squish
  config[:github_token] = ENV['GH_PERSONAL_TOKEN'].squish
  config[:github_repository] = ENV['GH_REPO'].squish
  config[:include_task_cards] = ENV['INCLUDE_TASK_CARDS'].to_s.downcase == 'true'
end

Config.preflight
