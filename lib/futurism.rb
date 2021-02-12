require "rails"
require "action_cable"
require "cable_ready"
require "futurism/engine"
require "futurism/message_verifier"
require "futurism/resolver/resources"
require "futurism/resolver/controller"
require "futurism/resolver/controller/renderer"
require "futurism/channel"
require "futurism/helpers"

module Futurism
  extend ActiveSupport::Autoload

  autoload :Helpers, "futurism/helpers"

  mattr_accessor :skip_in_test, default: false

  mattr_writer :default_controller
  def self.default_controller
    (@@default_controller || "::ApplicationController").to_s.constantize
  end

  ActiveSupport.on_load(:action_view) {
    include Futurism::Helpers
  }
end
