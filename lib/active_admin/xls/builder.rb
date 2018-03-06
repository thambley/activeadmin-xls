require 'stringio'
require 'spreadsheet'

module ActiveAdmin
  module Xls
    # Builder for xls data.
    class Builder
      include MethodOrProcHelper

      # @param [Class] resource_class The resource this builder generate column
      #   information for.
      # @param [Hash] options the options for the builder
      # @option options [Hash] :header_format a hash of format properties to
      #   apply to the header row. Any properties specified will be merged with
      #   the default header styles.
      # @option options [Array] :i18n_scope the I18n scope to use when looking
      #   up localized column headers.
      # @param [Block] block Block given will evaluated against this instance of
      #   Builder. That means you can call any method on the builder from within
      #   that block.
      # @example
      #   ActiveAdmin::Xls::Builder.new(Post, i18n: [:xls]) do
      #     delete_columns :id, :created_at, :updated_at
      #     column(:author_name) { |post| post.author.name }
      #     after_filter do |sheet|
      #       # todo
      #     end
      #   end
      #
      # @see DSL
      # @see https://github.com/zdavatz/spreadsheet/blob/master/lib/spreadsheet/format.rb
      def initialize(resource_class, options = {}, &block)
        @skip_header = false
        @resource_class = resource_class
        @columns = []
        @columns_loaded = false
        @column_updates = []
        parse_options options
        instance_eval(&block) if block_given?
      end

      # The default header style
      # @return [Hash]
      #
      # @see https://github.com/zdavatz/spreadsheet/blob/master/lib/spreadsheet/format.rb
      def header_format
        @header_format ||= {}
      end

      alias header_style header_format

      # This has can be used to override the default header style for your
      # sheet. Any values you provide will be merged with the default styles.
      # Precedence is given to your hash
      #
      # @example In Builder.new
      #   options = {
      #     header_format: { weight: :bold },
      #     i18n_scope: %i[xls post]
      #   }
      #   Builder.new(Post, options) do
      #     skip_header
      #   end
      #
      # @example With DSL
      #   ActiveAdmin.register Post do
      #     xls(header_format: { weight: :bold }, i18n_scope: %i[xls post]) do
      #       skip_header
      #     end
      #   end
      #
      # @example Simple DSL without block
      #   xls header_format: { weight: :bold }
      #
      # @see https://github.com/zdavatz/spreadsheet/blob/master/lib/spreadsheet/format.rb
      def header_format=(format_hash)
        @header_format = header_format.merge(format_hash)
      end

      alias header_style= header_format=

      # Indicates that we do not want to serialize the column headers
      #
      # @example In Builder.new
      #   options = {
      #     header_format: { weight: :bold },
      #     i18n_scope: %i[xls post]
      #   }
      #   Builder.new(Post, options) do
      #     skip_header
      #   end
      #
      # @example With DSL
      #   ActiveAdmin.register Post do
      #     xls(header_format: { weight: :bold }, i18n_scope: %i[xls post]) do
      #       skip_header
      #     end
      #   end
      def skip_header
        @skip_header = true
      end

      # The scope to use when looking up column names to generate the
      # report header
      attr_reader :i18n_scope

      # The I18n scope that will be used when looking up your
      # column names in the current I18n locale.
      # If you set it to [:active_admin, :resources, :posts] the
      # serializer will render the value at active_admin.resources.posts.title
      # in the current translations
      #
      # @note If you do not set this, the column name will be titleized.
      attr_writer :i18n_scope

      # The stored block that will be executed after your report is generated.
      #
      # @yieldparam sheet [Spreadsheet::Worksheet] the worksheet where the
      #   collection has been serialized
      #
      # @example With DSL
      #   xls do
      #     after_filter do |sheet|
      #       row_number = sheet.dimensions[1]
      #       sheet.update_row(row_number)
      #       row_number += 1
      #       sheet.update_row(row_number, 'Author Name', 'Number of Posts')
      #       users = collection.map(&:author).uniq(&:id)
      #       users.each do |user|
      #         row_number += 1
      #         sheet.update_row(row_number,
      #                          "#{user.first_name} #{user.last_name}",
      #                          user.posts.size)
      #       end
      #     end
      #   end
      def after_filter(&block)
        @after_filter = block
      end

      # the stored block that will be executed before your report is generated.
      #
      # @yieldparam sheet [Spreadsheet::Worksheet] the worksheet where the
      #   collection has been serialized
      #
      # @example with DSL
      #   xls do
      #     before_filter do |sheet|
      #       users = collection.map(&:author)
      #       users.each do |user|
      #         user.first_name = 'Set In Proc' if user.first_name == 'bob'
      #       end
      #       row_number = sheet.dimensions[1]
      #       sheet.update_row(row_number, 'Created', Time.zone.now)
      #       row_number += 1
      #       sheet.update_row(row_number, '')
      #     end
      #   end
      def before_filter(&block)
        @before_filter = block
      end

      # Returns the columns the builder will serialize.
      #
      # @return [Array<Column>] columns configued on the builder.
      def columns
        # execute each update from @column_updates
        # set @columns_loaded = true
        load_columns unless @columns_loaded
        @columns
      end

      # The collection we are serializing.
      #
      # @note This is only available after serialize has been called,
      # and is reset on each subsequent call.
      attr_reader :collection

      # Removes all columns from the builder. This is useful when you want to
      # only render specific columns. To remove specific columns use
      # ignore_column.
      #
      # @example Using alias whitelist
      #   Builder.new(Post, header_style: {}, i18n_scope: %i[xls post]) do
      #     whitelist
      #     column :title
      #   end
      def clear_columns
        @columns_loaded = true
        @column_updates = []

        @columns = []
      end

      # Clears the default columns array so you can whitelist only the columns
      # you want to export
      alias whitelist clear_columns

      # Add a column
      # @param [Symbol] name The name of the column.
      # @param [Proc] block A block of code that is executed on the resource
      #                     when generating row data for this column.
      #
      # @example With block
      #   xls(i18n_scope: [:rspec], header_style: { size: 20 }) do
      #     delete_columns :id, :created_at
      #     column(:author) { |post| post.author.first_name }
      #   end
      #
      # @example With default value
      #   Builder.new(Post, header_style: {}, i18n_scope: %i[xls post]) do
      #     whitelist
      #     column :title
      #   end
      def column(name, &block)
        if @columns_loaded
          columns << Column.new(name, block)
        else
          column_lambda = lambda do
            column(name, &block)
          end
          @column_updates << column_lambda
        end
      end

      # Removes columns by name.
      # Each column_name should be a symbol.
      #
      # @example In Builder.new
      #   options = {
      #     header_style: { size: 10, color: 'red' },
      #     i18n_scope: %i[xls post]
      #   }
      #   Builder.new(Post, options) do
      #     delete_columns :id, :created_at, :updated_at
      #     column(:author) do |resource|
      #       "#{resource.author.first_name} #{resource.author.last_name}"
      #     end
      #   end
      def delete_columns(*column_names)
        if @columns_loaded
          columns.delete_if { |column| column_names.include?(column.name) }
        else
          delete_lambda = lambda do
            delete_columns(*column_names)
          end
          @column_updates << delete_lambda
        end
      end

      # Removes all columns, and add columns by name.
      # Each column_name should be a symbol
      #
      # @example
      #   config.xls_builder.only_columns :title, :author
      def only_columns(*column_names)
        clear_columns
        column_names.each do |column_name|
          column column_name
        end
      end

      # Serializes the collection provided
      #
      # @param collection [Enumerable] list of resources to serialize
      # @param view_context object on which unknown methods may be executed
      # @return [Spreadsheet::Workbook]
      def serialize(collection, view_context = nil)
        @collection = collection
        @view_context = view_context
        load_columns unless @columns_loaded
        apply_filter @before_filter
        export_collection(collection)
        apply_filter @after_filter
        to_stream
      end

      # Xls column information
      class Column
        # @param name [String, Symbol] Name of the column. If the name of the
        #   column is an existing attribute of the resource class, the value
        #   can be retreived automatically if no block is specified
        # @param block [Proc] A procedure to generate data for the column
        #   instead of retreiving the value from the resource directly
        def initialize(name, block = nil)
          @name = name
          @data = block || @name
        end

        # @return [String, Symbol] Column name
        attr_reader :name

        # @return [String, Symbol, Proc] The column name used to look up the
        #   value, or a block used to generate the value to display.
        attr_reader :data

        # Returns a localized version of the column name if a scope is given.
        # Otherwise, it returns the titleized column name without translation.
        #
        # @param i18n_scope [String, Symbol, Array<String>, Array<Symbol>]
        #   Translation scope.  If not provided, the column name will be used.
        #
        # @see I18n
        def localized_name(i18n_scope = nil)
          return name.to_s.titleize unless i18n_scope
          I18n.t name, scope: i18n_scope
        end
      end

      private

      def load_columns
        return if @columns_loaded
        @columns = resource_columns(@resource_class)
        @columns_loaded = true
        @column_updates.each(&:call)
        @column_updates = []
        columns
      end

      def to_stream
        stream = StringIO.new('')
        book.write stream
        clean_up
        stream.string
      end

      def clean_up
        @book = @sheet = nil
      end

      def export_collection(collection)
        return if columns.none?
        row_index = sheet.dimensions[1]

        unless @skip_header
          header_row(sheet.row(row_index), collection)
          row_index += 1
        end

        collection.each do |resource|
          fill_row(sheet.row(row_index), resource_data(resource))
          row_index += 1
        end
      end

      # tranform column names into array of localized strings
      # @return [Array]
      def header_row(row, collection)
        apply_format_to_row(row, create_format(header_format))
        fill_row(row, header_data_for(collection))
      end

      def header_data_for(collection)
        resource = collection.first || @resource_class.new
        columns.map do |column|
          column.localized_name(i18n_scope) if in_scope(resource, column)
        end.compact
      end

      def apply_filter(filter)
        filter.call(sheet) if filter
      end

      def parse_options(options)
        options.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=") && !value.nil?
        end
      end

      def resource_data(resource)
        columns.map do |column|
          call_method_or_proc_on resource, column.data if in_scope(resource,
                                                                   column)
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
          column.each_value { |values| fill_row(row, values) }
        when Array
          column.each { |value| fill_row(row, value) }
        else
          # raise ArgumentError,
          #       "column #{column} has an invalid class (#{ column.class })"
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

      def respond_to_missing?(method_name, include_private = false)
        @view_context.respond_to?(method_name) || super
      end
    end
  end
end
