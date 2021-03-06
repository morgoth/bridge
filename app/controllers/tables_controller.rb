class TablesController < ApplicationController
  before_filter :login_required, :only => :create

  def index
    @tables = Table.all
  end

  def show
    @table = Table.find(params[:id])
  end

  def create
    @table = Table.create
    redirect_to @table
  end
end
