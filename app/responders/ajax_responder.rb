class AjaxResponder < ActionController::Responder
  def api_behavior(error)
    if get?
      render :action => default_action
    elsif has_errors?
      display(resource.errors, :status => :unprocessable_entity)
    else
      head :ok
    end
  end
end
