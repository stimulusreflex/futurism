require "fileutils"

namespace :futurism do
  desc "Let's look into a brighter future with futurism and CableReady"
  task install: :environment do
    system "yarn add @minthesize/futurism"

    filepath = %w[
      app/javascript/channels/index.js
      app/javascript/channels/index.ts
      app/javascript/packs/application.js
      app/javascript/packs/application.ts
    ]
      .select { |path| File.exist?(path) }
      .map { |path| Rails.root.join(path) }
      .first

    puts "Updating #{filepath}"
    lines = File.open(filepath, "r") { |f| f.readlines }

    unless lines.find { |line| line.start_with?("import * as Futurism") }
      matches = lines.select { |line| line =~ /\A(require|import)/ }
      lines.insert lines.index(matches.last).to_i + 1, "import * as Futurism from '@minthesize/futurism'\n"
    end

    unless lines.find { |line| line.start_with?("import consumer") }
      matches = lines.select { |line| line =~ /\A(require|import)/ }
      lines.insert lines.index(matches.last).to_i + 1, "import consumer from '../channels/consumer'\n"
    end

    initialize_line = lines.find { |line| line.start_with?("Futurism.initializeElements") }
    lines << "Futurism.initializeElements()\n" unless initialize_line

    subscribe_line = lines.find { |line| line.start_with?("Futurism.createSubscription") }
    lines << "Futurism.createSubscription(consumer)\n" unless subscribe_line

  end
end
