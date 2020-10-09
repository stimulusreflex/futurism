module Futurism
  module Helpers
    def futurize(records_or_string = nil, extends:, **options, &block)
      if Rails.env.test? && Futurism.skip_in_test
        if records_or_string.nil?
          return render **options
        else
          return render records_or_string, **options
        end
      end

      placeholder = capture(&block)

      if records_or_string.is_a?(ActiveRecord::Base) || records_or_string.is_a?(ActiveRecord::Relation)
        futurize_active_record(records_or_string, extends: extends, placeholder: placeholder, **options)
      elsif records_or_string.is_a?(String)
        html_options = options.delete(:html_options)
        futurize_with_options(extends: extends, placeholder: placeholder, partial: records_or_string, locals: options, html_options: html_options)
      else
        futurize_with_options(extends: extends, placeholder: placeholder, **options)
      end
    end

    def futurize_with_options(extends:, placeholder:, **options)
      collection = options.delete(:collection)
      if collection.nil?
        Element.new(extends: extends, placeholder: placeholder, options: options).render
      else
        collection_class_name = collection.klass.name
        as = options.delete(:as) || collection_class_name.downcase
        collection.map { |record|
          Element.new(extends: extends, placeholder: placeholder, options: options.deep_merge(locals: {as.to_sym => record})).render
        }.join.html_safe
      end
    end

    def futurize_active_record(records, extends:, placeholder:, **options)
      Array(records).map { |record|
        Element.new(extends: extends, options: options.merge(model: record), placeholder: placeholder).render
      }.join.html_safe
    end

    # wraps functionality for rendering a futurism element
    class Element
      include ActionView::Helpers

      attr_reader :extends, :placeholder, :html_options, :data_attributes, :model, :options, :eager

      def initialize(extends:, placeholder:, options:)
        @extends = extends
        @placeholder = placeholder
        @eager = options.delete(:eager)
        @html_options = options.delete(:html_options) || {}
        @data_attributes = html_options.fetch(:data, {}).except(:sgid, :signed_params)
        @model = options.delete(:model)
        @options = data_attributes.any? ? options.merge(data: data_attributes) : options
      end

      def dataset
        data_attributes.merge({
          signed_params: signed_params,
          sgid: model && model.to_sgid.to_s,
          eager: eager.presence
        })
      end

      def render
        case extends
        when :li
          content_tag :li, placeholder, html_options.deep_merge({data: dataset, is: "futurism-li"})
        when :tr
          content_tag :tr, placeholder, html_options.deep_merge({data: dataset, is: "futurism-table-row"})
        else
          content_tag :"futurism-element", placeholder, html_options.deep_merge({data: dataset})
        end
      end

      def transformed_options
        require_relative "shims/deep_transform_values" unless options.respond_to? :deep_transform_values

        options.deep_transform_values do |value|
          value.is_a?(ActiveRecord::Base) && !value.new_record? ? value.to_global_id.to_s : value
        end
      end

      private

      def signed_params
        Rails.application.message_verifier("futurism").generate(transformed_options)
      end
    end
  end
end
