# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
use Hassle if Rails.env.production? # make sass work on heroku
run Libre::Application
