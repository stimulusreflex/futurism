return unless defined?(ViewComponent)

def serialize_value(value)
  if value.is_a?(ActiveRecord::Base) && !value.new_record?
    value.to_global_id.to_s
  else
    value
  end
end

def deep_serialize_array(array)
  array.map do |value|
    if value.is_a?(Hash)
      require_relative "../shims/deep_transform_values" unless value.respond_to? :deep_transform_values
      value.deep_transform_values { |val| serialize_value(val) }
    else
      serialize_value(value)
    end
  end
end

module ViewComponent
  module FuturismSerializer
    def to_futurism_serialized
      deep_serialize_array(@raw_initialization_arguments).to_json
    end
  end

  class Base
    # Override base new method so that we can hack into the
    # initialization process for each view component
    # Ideally, a PR to the ViewComponent team would allow us to remove our implementation
    # include FuturismSerializer

    def self.new(*arguments, &block)
      instance = allocate
      instance.singleton_class.include(FuturismSerializer)
      instance.instance_variable_set("@raw_initialization_arguments", arguments)
      instance.send(:initialize, *arguments, &block)
      instance
    end
  end
end
