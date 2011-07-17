ActionController::Base.wrap_parameters format: [:json]

if defined?(ActiveRecord)
  ActiveRecord::Base.include_root_in_json = false
end
