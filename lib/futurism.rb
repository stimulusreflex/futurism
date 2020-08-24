require "rails"
require "action_cable"
require "cable_ready"
require "futurism/engine"
require "futurism/channel"
require "futurism/helpers"

module Futurism
  extend ActiveSupport::Autoload

  autoload :Helpers, "futurism/helpers"

  ActiveSupport.on_load(:action_view) {
    include Futurism::Helpers
  }
end
