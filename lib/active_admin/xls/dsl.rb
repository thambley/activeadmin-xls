module ActiveAdmin
  module Xls
    # extends activeadmin dsl to include xls
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
