module ActiveAdmin
  module Xls
    module DSL
      delegate(:ingnore_columns, :column, :after_filer, :i18n_scope, :header_style, :skip_header, :white_list,
               to: :xls_builder,
               prefix: :config)

      def xls(options = {}, &block)
        config.xls_builder = ActiveAdmin::Xls::Builder.new(config.resource_class, options, &block)
      end
    end
  end
end
