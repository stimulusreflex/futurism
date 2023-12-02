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
  mattr_accessor :instrumentation, default: false
  mattr_accessor :logger

  mattr_writer :default_controller
  def self.default_controller
    (@@default_controller || "::ApplicationController").to_s.constantize
  end

  def self.skip_in_test?
    skip_in_test.present?
  end

  def self.instrumentation?
    instrumentation.present?
  end

  ActiveSupport.on_load(:action_view) do
    include Futurism::Helpers
  end
end
