module Futurism
  module OptionsTransformer
    def dump_options(options)
      require_relative "shims/deep_transform_values" unless options.respond_to? :deep_transform_values

      options.deep_transform_values do |value|
        next(value) unless value.respond_to?(:to_global_id)
        next(value) if value.is_a?(ActiveRecord::Base) && value.new_record?

        value.to_global_id.to_s
      end
    end

    def load_options(options)
      require_relative "shims/deep_transform_values" unless options.respond_to? :deep_transform_values

      options.deep_transform_values { |value| (value.is_a?(String) && value.start_with?("gid://")) ? GlobalID::Locator.locate(value) : value }
    end
  end
end
