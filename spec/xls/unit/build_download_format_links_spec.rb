require 'spec_helper'
describe ActiveAdmin::Views::PaginatedCollection do
  def arbre(assigns = {}, helpers = mock_action_view, &block)
    Arbre::Context.new(assigns, helpers, &block)
  end

  def render_arbre_component(assigns = {}, helpers = mock_action_view, &block)
    arbre(assigns, helpers, &block).children.first
  end

  # Returns a fake action view instance to use with our renderers
  def mock_action_view(assigns = {})
    controller = ActionView::TestCase::TestController.new
    ActionView::Base.send :include, ActionView::Helpers
    ActionView::Base.send :include, ActiveAdmin::ViewHelpers
    ActionView::Base.send :include, Rails.application.routes.url_helpers
    ActionView::Base.new(ActionController::Base.view_paths, assigns, controller)
  end

  let(:view) do
    view = mock_action_view
    allow(view.request).to receive(:query_parameters) { { page: '1' } }
    allow(view.request).to receive(:path_parameters) do
      { controller: 'admin/posts', action: 'index' }
    end
    view
  end

  # Helper to render paginated collections within an arbre context
  def paginated_collection(*args)
    render_arbre_component({ paginated_collection_args: args }, view) do
      paginated_collection(*paginated_collection_args)
    end
  end

  let(:collection) do
    posts = [Post.new(title: 'First Post')]
    Kaminari.paginate_array(posts).page(1).per(5)
  end

  let(:pagination) { paginated_collection(collection) }

  before do
    allow(collection).to receive(:except) { collection } unless collection.respond_to? :except
    allow(collection).to receive(:group_values) { [] } unless collection.respond_to? :group_values
    allow(collection).to receive(:reorder) { collection }
  end

  it 'renders the xls download link' do
    expect(pagination.children.last.content).to match(/XLS/)
  end
end
