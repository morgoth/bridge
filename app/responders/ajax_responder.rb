class AjaxResponder < ActionController::Responder
  def display(resource, given_options={})
    user = controller.send(:current_user)
    controller.render given_options.merge!(options).merge!(format => resource.send(:"as_#{format}", :user => user))
  end

  def api_behavior(error)
    if get?
      display(resource)
    elsif has_errors?
      display(resource.errors, :status => :unprocessable_entity)
    elsif post?
      display(resources.is_a?(Array) ? resources.first : resources)
    else
      head :ok
    end
  end
end
