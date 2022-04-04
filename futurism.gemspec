$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "futurism/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "futurism"
  spec.version = Futurism::VERSION
  spec.authors = ["Julian Rubisch"]
  spec.email = ["julian@julianrubisch.at"]
  spec.homepage = "https://github.com/stimulusreflex/futurism"
  spec.summary = "Lazy-load Rails partials via CableReady"
  spec.description = "Uses custom html elements with attached IntersectionObserver to automatically lazy load partials via websockets"
  spec.license = "MIT"

  spec.files = Dir[
    "lib/**/*.rb",
    "app/**/*.rb",
    "app/assets/javascripts/*",
    "bin/*",
    "[A-Z]*"
  ]

  spec.test_files = Dir["test/**/*.rb"]

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "pry", "~> 0.12.2"
  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency "standardrb"
  spec.add_development_dependency "sqlite3"

  spec.add_dependency "rack", "~> 2.0"
  spec.add_dependency "rails", ">= 5.2"
  spec.add_dependency "cable_ready", "= 5.0.0.pre9"
end
