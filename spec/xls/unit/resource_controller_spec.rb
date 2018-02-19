require 'spec_helper'
describe ActiveAdmin::ResourceController do
  let(:mime) { Mime::Type.lookup_by_extension(:xls) }

  let(:request) do
    ActionController::TestRequest.new.tap do |test_request|
      test_request.accept = mime
    end
  end

  let(:response) { ActionController::TestResponse.new }

  let(:controller) do
    Admin::CategoriesController.new.tap do |controller|
      controller.request = request
      controller.response = response
    end
  end

  let(:filename) do
    "#{controller.resource_class.to_s.downcase.pluralize}-#{Time.now.strftime('%Y-%m-%d')}.xls"
  end

  it 'generates an xls filename' do
    expect(controller.xls_filename).to eq(filename)
  end

  context 'when making requests with the xls mime type' do
    it 'returns xls attachment when requested' do
      controller.send :index
      disposition = "attachment; filename=\"#{filename}\""
      expect(response.headers['Content-Disposition']).to eq(disposition)
      expect(response.headers['Content-Transfer-Encoding']).to eq('binary')
    end

    it 'returns max_csv_records for per_page' do
      # this might need to go away!
      max_csv_records = if controller.respond_to?(:max_csv_records, true)
                          controller.send(:max_csv_records)
                        else
                          controller.send(:per_page)
                        end
      expect(controller.send(:per_page)).to eq(max_csv_records)
    end

    it 'uses the default per_page when we do not specify xls mime type' do
      controller.request.accept = 'text/html'
      aa_default_per_page = ActiveAdmin.application.default_per_page
      expect(controller.send(:per_page)).to eq(aa_default_per_page)
    end
  end
end
