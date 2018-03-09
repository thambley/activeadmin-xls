module ActiveAdmin
  module Xls
    # Extends activeadmin dsl to include xls
    module DSL
      delegate(:after_filter,
               :before_filter,
               :column,
               :delete_columns,
               :header_format,
               :header_style,
               :i18n_scope,
               :only_columns,
               :skip_header,
               :whitelist,
               to: :xls_builder,
               prefix: :config)

      # Creates a default XLS Builder to respond to xls requests for this
      # resource. Options are passed to the Builder initialize method.
      #
      # @param [Hash] options the options for the builder
      # @option options [Hash] :header_format a hash of format properties to
      #   apply to the header row. Any properties specified will be merged with
      #   the default header styles.
      # @option options [Array] :i18n_scope the I18n scope to use when looking
      #   up localized column headers.
      # @param [Block] block block given will evaluated against the instance of
      #   Builder. That means you can call any method on the builder from within
      #   that block.
      # @return A new instance of Builder
      #
      # @example Using the DSL
      #   xls(i18n_scope: [:active_admin, :xls, :post],
      #       header_format: { weight: :bold, color: :blue }) do
      #     # Specify that you want to white list column output.
      #     # whitelist
      #
      #     # Do not serialize the header, only output data.
      #     # skip_header
      #
      #     # restrict columns to a list without customization
      #     # only_columns :title, :author
      #
      #     # deleting columns from the report
      #     delete_columns :id, :created_at, :updated_at
      #
      #     # adding a column to the report with customization
      #     column(:author) do |post|
      #       "#{post.author.first_name} #{post.author.last_name}"
      #     end
      #
      #     # inserting additional data with after_filter
      #     after_filter do |sheet|
      #       # todo
      #     end
      #
      #     # inserting data with before_filter
      #     before_filter do |sheet|
      #       # todo
      #     end
      #   end
      #
      # @see Builder
      # @see https://github.com/zdavatz/spreadsheet/blob/master/lib/spreadsheet/format.rb
      def xls(options = {}, &block)
        config.xls_builder = ActiveAdmin::Xls::Builder.new(
          config.resource_class,
          options,
          &block
        )
      end
    end
  end
end
