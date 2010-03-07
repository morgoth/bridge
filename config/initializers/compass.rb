Compass.configuration do |config|
  config.project_type = :rails
  config.project_path = Rails.root if defined?(Rails.root)
  config.css_dir = "public/stylesheets/compiled"
  config.sass_dir = "app/stylesheets"
  config.images_dir = "public/images"
  config.javascripts_dir = "public/javascripts"
  config.output_style = :compact
  config.http_images_path = "/images"
  config.environment = Rails.env.to_sym
end
Compass.configure_sass_plugin!