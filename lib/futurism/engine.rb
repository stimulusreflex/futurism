module Futurism
  class Engine < ::Rails::Engine
    initializer "futurism.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.precompile += %w[
          futurism.js
          futurism.min.js
          futurism.min.js.map
          futurism.umd.js
          futurism.umd.min.js
          futurism.umd.min.js.map
        ]
      end
    end

    initializer "futurism.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << Engine.root.join("lib/futurism/importmap.rb")
        app.config.importmap.cache_sweepers << Engine.root.join("app/assets/javascripts")
      end
    end

    initializer "futurism.logger", after: "initialize_logger" do
      Futurism.logger ||= Rails.logger || Logger.new($stdout)
    end
  end
end
