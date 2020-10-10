require "rails"
require "action_cable"
require "cable_ready"
require "futurism/engine"
require "futurism/channel"
require "futurism/helpers"
require "futurism/shims/view_component_serializer"

module Futurism
  extend ActiveSupport::Autoload

  autoload :Helpers, "futurism/helpers"

  mattr_accessor :skip_in_test

  ActiveSupport.on_load(:action_view) {
    include Futurism::Helpers
  }
end
