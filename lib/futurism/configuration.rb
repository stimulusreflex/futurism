module Futurism
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    alias_method :config, :configuration
  end

  class Configuration
    attr_accessor :parent_channel

    def initialize
      @parent_channel = "::ApplicationCable::Channel"
    end
  end
end
