require "rails"

module Hancock
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)

    def copy_files
      copy_file "hancock.rb", "config/initializers/hancock.rb"
    end
  end
end