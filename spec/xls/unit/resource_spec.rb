require 'spec_helper' 
include ActiveAdmin

module ActiveAdmin
  module Xls
    describe Resource do
      let(:resource) { ActiveAdmin.register(Post) }

      let(:custom_builder) do
        Builder.new(Post) do |builder|
          column(:fake) { :fake }
        end
      end

      context 'when registered' do
        it "each resource has an xls_builer" do
          resource.xls_builder.should be_a(Builder)
        end

        it "We can specify our own configured builder" do
          lambda { resource.xls_builder = custom_builder }.should_not raise_error
        end
      end
    end
  end
end
