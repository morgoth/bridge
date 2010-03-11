class AjaxResponder < ActionController::Responder
  def display(resource, given_options={})
    user = controller.send(:current_user)
    controller.render given_options.merge!(options).merge!(format => resource.send(:for_ajax, user))
  end

  def api_behavior(error)
    if get?
      display(resource)
    elsif has_errors?
      display(resource.errors, :status => :unprocessable_entity)
    else
      head :ok
    end
  end
end