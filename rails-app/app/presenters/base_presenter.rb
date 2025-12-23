class BasePresenter < SimpleDelegator
  def initialize(model, view_context = nil)
    super(model)
    @model = model
    @view_context = view_context
  end

  def h
    @view_context
  end

  def model
    __getobj__
  end
  alias_method :object, :model
end

