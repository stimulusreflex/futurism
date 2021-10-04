module Futurism
  module Helpers
    def futurize(records_or_string = nil, extends:, **options, &block)
      if Rails.env.test? && Futurism.skip_in_test
        if records_or_string.nil?
          return render(**options)
        else
          return render(records_or_string, **options)
        end
      end

      options[:eager] = true unless block_given?

      if records_or_string.is_a?(ActiveRecord::Base) || records_or_string.is_a?(ActiveRecord::Relation)
        futurize_active_record(records_or_string, extends: extends, **options, &block)
      elsif records_or_string.is_a?(String)
        html_options = options.delete(:html_options)
        futurize_with_options(extends: extends, partial: records_or_string, locals: options, html_options: html_options, &block)
      else
        futurize_with_options(extends: extends, **options, &block)
      end
    end

    def futurize_with_options(extends:, **options, &block)
      collection = options.delete(:collection)
      if collection.nil?
        placeholder = capture(&block) if block_given?

        WrappingFuturismElement.new(extends: extends, placeholder: placeholder, options: options).render
      else
        collection_class_name = collection.try(:klass).try(:name) || collection.first.class.to_s
        as = options.delete(:as) || collection_class_name.underscore
        broadcast_each = options.delete(:broadcast_each) || false

        collection.each_with_index.map { |record, index|
          placeholder = capture(record, index, &block) if block_given?

          WrappingFuturismElement.new(extends: extends, placeholder: placeholder, options: options.deep_merge(
            broadcast_each: broadcast_each,
            locals: {as.to_sym => record, "#{as}_counter".to_sym => index}
          )).render
        }.join.html_safe
      end
    end

    def futurize_active_record(records, extends:, **options, &block)
      Array(records).map.with_index { |record, index|
        placeholder = capture(record, index, &block) if block_given?

        WrappingFuturismElement.new(extends: extends, options: options.merge(model: record), placeholder: placeholder).render
      }.join.html_safe
    end

    # wraps functionality for rendering a futurism element
    class WrappingFuturismElement
      include ActionView::Helpers
      include Futurism::MessageVerifier

      attr_reader :placeholder, :html_options, :data_attributes, :model, :options, :eager, :broadcast_each, :controller

      def initialize(extends:, placeholder:, options:)
        @extends = extends
        @placeholder = placeholder
        @eager = options.delete(:eager)
        @broadcast_each = options.delete(:broadcast_each)
        @controller = options.delete(:controller)
        @html_options = options.delete(:html_options) || {}
        @data_attributes = html_options.fetch(:data, {}).except(:sgid, :signed_params)
        @model = options.delete(:model)
        @options = data_attributes.any? ? options.merge(data: data_attributes) : options
      end

      def dataset
        data_attributes.merge({
          signed_params: signed_params,
          sgid: model && model.to_sgid.to_s,
          eager: eager.presence,
          broadcast_each: broadcast_each.presence,
          signed_controller: signed_controller
        })
      end

      def render
        content_tag :"futurism-element", placeholder, html_options.deep_merge({data: dataset, extends: extends})
      end

      def transformed_options
        require_relative "shims/deep_transform_values" unless options.respond_to? :deep_transform_values

        options.deep_transform_values do |value|
          next(value) unless value.respond_to?(:to_global_id)
          next(value) if value.is_a?(ActiveRecord::Base) && value.new_record?

          value.to_global_id.to_s
        end
      end

      private

      def signed_params
        message_verifier.generate(transformed_options)
      end

      def signed_controller
        return unless controller.present?

        message_verifier.generate(controller.to_s)
      end

      def extends
        # TODO remove this in the next major version
        case @extends
        when :li then "list-item"
        when :tr then "table-row"
        else @extends
        end
      end
    end
  end
end
