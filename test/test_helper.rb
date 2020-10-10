# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "view_component"
require_relative "../test/dummy/config/environment"
require "rails/test_help"
require "nokogiri"
require "pry"
require "spy/integration"

# Filter out the backtrace from minitest while preserving the one from other libraries.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new
