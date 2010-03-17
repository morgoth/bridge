module BoardsTableExtension
  def current
    order("position DESC").first
  end
end
