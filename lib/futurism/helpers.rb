module Futurism
  module Helpers
    def futurize(records_or_string = nil, extends:, **options, &block)
      placeholder = capture(&block)

      if records_or_string.is_a?(ActiveRecord::Base) || records_or_string.is_a?(ActiveRecord::Relation)
        futurize_active_record(records_or_string, extends: extends, placeholder: placeholder, **options)
      elsif records_or_string.is_a?(String)
        futurize_with_options(extends: extends, partial: records_or_string, locals: options, placeholder: placeholder)
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

      attr_reader :extends, :placeholder, :html_options, :model, :options

      def initialize(extends:, placeholder:, options:)
        @extends = extends
        @placeholder = placeholder
        @html_options = options.delete(:html_options) || {}
        @model = options.delete(:model)
        @options = options
      end

      def dataset
        {
          signed_params: signed_params,
          sgid: model && model.to_sgid.to_s
        }
      end

      def render
        case extends
        when :li
          content_tag :li, placeholder, {data: dataset, is: "futurism-li"}.merge(html_options)
        when :tr
          content_tag :tr, placeholder, {data: dataset, is: "futurism-table-row"}.merge(html_options)
        else
          content_tag :"futurism-element", placeholder, {data: dataset}.merge(html_options)
        end
      end

      private

      def signed_params
        Rails.application.message_verifier("futurism").generate(options)
      end
    end
  end
end
