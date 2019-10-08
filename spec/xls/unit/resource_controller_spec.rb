require 'spec_helper'
describe Admin::CategoriesController, type: :controller do
  let(:mime) { Mime::Type.lookup_by_extension(:xls) }

  let(:filename) do
    "categories-#{Time.now.strftime('%Y-%m-%d')}.xls"
  end

  it 'generates an xls filename' do
    expect(controller.xls_filename).to eq(filename)
  end

  context 'when making requests with the xls mime type' do
    it 'returns xls attachment when requested' do
      request.accept = mime
      get :index
      disposition = "attachment; filename=\"#{filename}\""
      expect(response.headers['Content-Disposition']).to eq(disposition)
      expect(response.headers['Content-Transfer-Encoding']).to eq('binary')
    end
  end
end
