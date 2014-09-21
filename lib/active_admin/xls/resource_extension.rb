module ActiveAdmin
  module Xls
    module ResourceExtension
      def xls_builder=(builder)
        @xls_builder = builder
      end

      def xls_builder
        @xls_builder ||= ActiveAdmin::Xls::Builder.new(resource_class)
      end
    end
  end
end
