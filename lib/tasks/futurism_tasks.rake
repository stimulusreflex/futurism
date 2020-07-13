require "fileutils"

namespace :futurism do
  desc "Let's look into a brighter future with futurism and CableReady"
  task install: :environment do
    system "yarn add cable_ready"

    app_path_part = Webpacker && Rails ? Webpacker.config.source_path.relative_path_from(Rails.root) : "app/javascript"

    FileUtils.mkdir_p "./#{app_path_part}/channels"
    FileUtils.mkdir_p "./#{app_path_part}/elements"

    FileUtils.cp File.expand_path("../templates/futurism_channel.js", __dir__), "./#{app_path_part}/channels"
    FileUtils.cp_r File.expand_path("../templates/elements", __dir__), "./#{app_path_part}"

    filepath = %w[
      app/javascript/packs/application.js
      app/javascript/packs/application.ts
    ]
      .select { |path| File.exist?(path) }
      .map { |path| Rails.root.join(path) }
      .first

    puts "Updating #{filepath}"
    lines = File.open(filepath, "r") { |f| f.readlines }

    unless lines.find { |line| line.include?("import 'elements'") }
      lines << "\nimport 'elements'"
      File.open(filepath, "w") { |f| f.write lines.join }
    end

  end
end
