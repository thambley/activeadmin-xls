require 'stringio'
require 'spreadsheet'

module ActiveAdmin
  module Xls
    # Builder for xls data.
    class Builder

      include MethodOrProcHelper

      # @param resource_class The resource this builder generate column information for.
      # @param [Hash] options the options for this builder
      # @option [Hash] :header_format - a hash of format properties to apply
      #   to the header row. Any properties specified will be merged with the default
      #   header styles. @see https://github.com/zdavatz/spreadsheet/blob/master/lib/spreadsheet/format.rb
      # @option [Array] :i18n_scope - the I18n scope to use when looking
      #   up localized column headers.
      # @param [Block] Any block given will evaluated against this instance of Builder.
      #   That means you can call any method on the builder from withing that block.
      # @example
      #   ActiveAdmin::Xls:Builder.new(Post, i18n: [:xls]) do
      #     delete_columns :id, :created_at, :updated_at
      #     column(:author_name) { |post| post.author.name }
      #     after_filter { |sheet|
      #       
      #     }
      #   end
      #   @see ActiveAdmin::Axlsx::DSL
      def initialize(resource_class, options = {}, &block)
        @skip_header = false
        @columns = resource_columns(resource_class)
        parse_options options
        instance_eval &block if block_given?
      end

      # The default header style
      # @return [Hash]
      def header_format
        @header_format ||= {}
      end

      # This has can be used to override the default header style for your
      # sheet. Any values you provide will be merged with the default styles.
      # Precidence is given to your hash
      # @see https://github.com/zdavatz/spreadsheet/blob/master/lib/spreadsheet/format.rb 
      # for more details on how to create and apply style.
      def header_format=(format_hash)
        @header_format = header_format.merge(format_hash)
      end

      # Indicates that we do not want to serialize the column headers
      def skip_header
        @skip_header = true
      end

      # The scope to use when looking up column names to generate the report header
      def i18n_scope
        @i18n_scope ||= nil
      end

      # This is the I18n scope that will be used when looking up your
      # colum names in the current I18n locale.
      # If you set it to [:active_admin, :resources, :posts] the
      # serializer will render the value at active_admin.resources.posts.title in the
      # current translations
      # @note If you do not set this, the column name will be titleized.
      def i18n_scope=(scope)
        @i18n_scope = scope
      end

      # The stored block that will be executed after your report is generated.
      def after_filter(&block)
        @after_filter = block
      end

      # the stored block that will be executed before your report is generated.
      def before_filter(&block)
        @before_filter = block
      end

      # The columns this builder will be serializing
      attr_reader :columns

      # The collection we are serializing.
      # @note This is only available after serialize has been called,
      # and is reset on each subsequent call.
      attr_reader :collection

      # removes all columns from the builder. This is useful when you want to
      # only render specific columns. To remove specific columns use ignore_column.
      def clear_columns
        @columns = []
      end

      # Clears the default columns array so you can whitelist only the columns you
      # want to export
      def whitelist
        @columns = []
      end

      # Add a column
      # @param [Symbol] name The name of the column.
      # @param [Proc] block A block of code that is executed on the resource
      #                     when generating row data for this column.
      def column(name, &block)
        @columns << Column.new(name, block)
      end

      # removes columns by name
      # each column_name should be a symbol
      def delete_columns(*column_names)
        @columns.delete_if { |column| column_names.include?(column.name) }
      end

      # Serializes the collection provided
      # @return [Spreadsheet::Workbook]
      def serialize(collection, view_context)
        @collection = collection
        @view_context = view_context
        apply_filter @before_filter
        export_collection(collection)
        apply_filter @after_filter
        to_stream
      end

      protected

      class Column
        def initialize(name, block = nil)
          @name = name
          @data = block || @name
        end

        attr_reader :name, :data

        def localized_name(i18n_scope = nil)
          return name.to_s.titleize unless i18n_scope
          I18n.t name, scope: i18n_scope
        end
      end

      private

      def to_stream
        stream = StringIO.new("")
        book.write stream
        clean_up
        stream.string
      end

      def clean_up
        @book = @sheet = nil
      end

      def export_collection(collection)
        if columns.any?
          row_index = 0

          unless @skip_header
            header_row(collection)
            row_index = 1
          end
          
          collection.each do |resource|
            row = sheet.row(row_index)
            if (style_hash = resource.try(:xls_style)).present?
              apply_format_to_row(row, Spreadsheet::Format.new(style_hash))
            end  
            fill_row(row, resource_data(resource))
            row_index += 1
          end
        end
      end

      # tranform column names into array of localized strings
      # @return [Array]
      def header_row(collection)
        row = sheet.row(0)
        apply_format_to_row(row, create_format(header_format))
        fill_row(row, header_data_for(collection))
      end

      def header_data_for(collection)
        resource = collection.first
        columns.map do |column|
          column.localized_name(i18n_scope) if in_scope(resource, column)
        end.compact
      end

      def apply_filter(filter)
        filter.call(sheet) if filter
      end

      def parse_options(options)
        options.each do |key, value|
          self.send("#{key}=", value) if self.respond_to?("#{key}=") && value != nil
        end
      end

      def resource_data(resource)
        columns.map  do |column|
          call_method_or_proc_on resource, column.data if in_scope(resource, column)
        end
      end

      def in_scope(resource, column)
        return true unless column.name.is_a?(Symbol)
        resource.respond_to?(column.name)
      end

      def sheet
        @sheet ||= book.create_worksheet
      end

      def book
        @book ||= ::Spreadsheet::Workbook.new
      end

      def resource_columns(resource)
        [Column.new(:id)] + resource.content_columns.map do |column|
          Column.new(column.name.to_sym)
        end
      end
      
      def create_format(format_hash)
        Spreadsheet::Format.new format_hash
      end
      
      def apply_format_to_row(row, format)
        row.default_format = format if format
      end
      
      def fill_row(row, column)
        case column
        when Hash
          column.each{|key, values| fill_row(row, values)}
        when Array
          column.each{|value| fill_row(row, value)}
        else
          #raise ArgumentError, "column #{column} has an invalid class (#{ column.class })"
          row.push(column)
        end
      end

      def method_missing(method_name, *arguments)
        if @view_context.respond_to? method_name
          @view_context.send method_name, *arguments
        else
          super
        end
      end
    end
  end
end
