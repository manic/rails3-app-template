# rails new APP_NAME -T -J -d mysql -m rails3-app-template/rails3.rb
#
# >----------------------------[ Initial Setup ]------------------------------<

initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
end
RUBY

def say_recipe(name); say "\033[36m" + "recipe".rjust(10) + "\033[0m" + "    Running #{name} recipe..." end
def say_wizard(text); say "\033[36m" + "wizard".rjust(10) + "\033[0m" + "    #{text}" end

# remove files
say_recipe 'remove files'
remove_file "README"
remove_file "public/index.html"
remove_file "public/images/rails.png"
run "cp config/database.yml config/database.yml.example"

# install gems
say_recipe 'install gems'
remove_file "Gemfile"
copy_file   "#{File.dirname(rails_template)}/Gemfile", "Gemfile"

# bundle install
run "bundle install"

# generate rspec
say_recipe 'install rspec'
generate "rspec:install"

say_recipe 'setup environment'
# copy files
copy_file  "#{File.dirname(rails_template)}/watchr.rb",   "script/watchr.rb"
copy_file  "#{File.dirname(rails_template)}/dev.rake",    "lib/tasks/dev/rake"

# remove active_resource and test_unit
gsub_file 'config/application.rb', /require 'rails\/all'/, <<-CODE
  require 'rails'
  require 'active_record/railtie'
  require 'action_controller/railtie'
  require 'action_mailer/railtie'
CODE

# install jquery
inside "public/javascripts" do
  get "https://github.com/rails/jquery-ujs/raw/master/src/rails.js", "rails.js"
  get "http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js", "jquery.js"
end


application "config.action_view.javascript_expansions[:defaults] = %w(jquery rails)"

# add time format
environment 'Time::DATE_FORMATS.merge!(:default => "%Y/%m/%d %I:%M %p", :ymd => "%Y/%m/%d")'

# .gitignore
say_recipe 'setup .gitignore'
append_file '.gitignore', <<-CODE
config/database.yml
Thumbs.db
.DS_Store
tmp/*
coverage/*
CODE

# keep tmp and log
empty_directory_with_gitkeep "tmp"
empty_directory_with_gitkeep "log"

# git commit
say_recipe 'git commit'
git :init
git :add => '.'
git :add => 'tmp/.gitkeep -f'
git :add => 'log/.gitkeep -f'
git :commit => "-a -m 'initial commit'"