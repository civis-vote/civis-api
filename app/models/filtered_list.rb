class FilteredList
  attr_reader :data, :facets, :paging

  def initialize(paginated_list, filter_params)
    self.data   = paginated_list
    self.paging = paginated_list
    self.facets = {data: paginated_list, params: filter_params}
  end

  def data=(data)
    @data = []
    @data = data unless data.blank?
  end

  def facets=(arguments)
    data = arguments[:data]
    params = arguments[:params]
  end

  def paging=(paginated_list)
    @paging = {
      total_items:  paginated_list.total_count,
      current_page: paginated_list.current_page,
      total_pages:  paginated_list.total_pages
    }
  end
end