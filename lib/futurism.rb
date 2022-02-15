require "rails"


require "action_cable"
require "cable_ready"
require "futurism/configuration"
require "futurism/engine"
require "futurism/message_verifier"
require "futurism/options_transformer"
require "futurism/resolver/resources"
require "futurism/resolver/controller"
require "futurism/resolver/controller/renderer"
require "futurism/helpers"

module Futurism
  extend ActiveSupport::Autoload

  autoload :Helpers, "futurism/helpers"

  mattr_accessor :skip_in_test, default: false

  mattr_writer :default_controller
  def self.default_controller
    (@@default_controller || "::ApplicationController").to_s.constantize
  end

  ActiveSupport.on_load(:action_view) do
    include Futurism::Helpers
  end

  mattr_accessor :logger
  self.logger ||= Rails.logger ? Rails.logger.new : Logger.new($stdout)
end
