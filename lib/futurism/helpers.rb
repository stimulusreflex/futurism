module Futurism
  module Helpers
    def futurize(records_or_string = nil, extends:, **options, &block)
      if (Rails.env.test? && Futurism.skip_in_test) || options[:unless]
        if records_or_string.nil?
          return render(**options)
        else
          return render(records_or_string, **options)
        end
      end

      options[:eager] = true unless block_given?

      # cannot serialize a proc
      options.delete(:cached) if options[:cached].is_a?(Proc)

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
      include Futurism::OptionsTransformer

      attr_reader :extends, :placeholder, :html_options, :data_attributes, :model, :options, :eager, :broadcast_each, :controller

      def initialize(extends:, placeholder:, options:)
        @extends = extends
        @placeholder = placeholder
        @eager = options.delete(:eager)
        @broadcast_each = options.delete(:broadcast_each)
        @controller = options.delete(:controller)
        @updates_for_object = options.delete(:updates_for)
        @html_options = options.delete(:html_options) || {}
        @data_attributes = html_options.fetch(:data, {}).except(:sgid, :signed_params)
        @model = options.delete(:model)
        @wrapped_for_updates_for = options.delete(:wrapped_for_updates_for)
        if @wrapped_for_updates_for
          @html_options[:keep] = 'keep'
          @data_attributes['updates-for'] = true
        end
        @options = data_attributes.any? ? options.merge(data: data_attributes) : options

        warn "[Futurism] `updates_for` feature is not available for extends: :li or :tr elements." if [:tr, :li].include?(extends)
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
        return render_updates_for if use_updates_for?

        render_tag
      end

      def transformed_options
        dump_options(options)
      end

      private

      ############
      # TODO: Include CableReadyHelper
      include CableReady::Compoundable
      include CableReady::StreamIdentifier
      include ActionView::Context

      def updates_for(*keys, url: nil, debounce: nil, only: nil, html_options: {}, &block)
        options = build_options(*keys, html_options)
        options[:url] = url if url
        options[:debounce] = debounce if debounce
        options[:only] = only if only
        tag.updates_for(**options) { capture(&block) }
      end

      private

      def build_options(*keys, html_options)
        keys.select!(&:itself)
        {identifier: signed_stream_identifier(compound(keys))}.merge(html_options)
      end
      ############

      def render_updates_for
        arguments = Array.wrap(@updates_for_object)
        kwargs = arguments.last.is_a?(Hash) ? arguments.pop : {}
        kwargs[:html_options] ||= {}
        kwargs[:html_options][:data] ||= {}
        kwargs[:html_options][:data]['ignore-morph'] = true
        kwargs[:html_options][:data]['after-update-event-selector'] = 'futurism-element'

        updates_for(*arguments, **kwargs) do
          render_tag
        end
      end

      def render_tag
        case extends
        when :li
          content_tag :li, placeholder, html_options.deep_merge({data: dataset, is: "futurism-li"})
        when :tr
          content_tag :tr, placeholder, html_options.deep_merge({data: dataset, is: "futurism-table-row"})
        else
          content_tag :"futurism-element", placeholder, html_options.deep_merge({data: dataset})
        end
      end

      def use_updates_for?
        @updates_for_object.present? && ![:tr, :li].include?(extends)
      end

      def signed_params
        message_verifier.generate(transformed_options.merge(updates_for_params))
      end

      def updates_for_params
        return {} unless use_updates_for? || @wrapped_for_updates_for

        {
          wrap_for_updates_for: {
            extends: extends,
            html_options: html_options,
            data_attributes: data_attributes,
          }
        }
      end

      def signed_controller
        return unless controller.present?

        message_verifier.generate(controller.to_s)
      end
    end
  end
end
