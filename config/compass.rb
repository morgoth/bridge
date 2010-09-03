project_type = :rails
project_path = Rails.root if defined?(Rails.root)
css_dir = "tmp/public/stylesheets"
sass_dir = "app/stylesheets"
images_dir = "public/images"
javascripts_dir = "public/javascripts"
output_style = :compact
http_images_path = "/images"
environment = Rails.env.to_sym
asset_cache_buster { nil }
