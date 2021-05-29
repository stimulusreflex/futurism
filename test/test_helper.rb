# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
require "rails/test_help"
require "minitest/mock"
require "nokogiri"
require "pry"

# Filter out the backtrace from minitest while preserving the one from other libraries.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Turn off logger output as to not have poor test output
Futurism.logger = Logger.new(IO::NULL)
