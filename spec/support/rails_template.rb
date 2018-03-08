# Rails template to build the sample app for specs

# Create a cucumber database and environment
copy_file File.expand_path('../templates/cucumber.rb', __FILE__),
          'config/environments/cucumber.rb'
copy_file File.expand_path('../templates/cucumber_with_reloading.rb', __FILE__),
          'config/environments/cucumber_with_reloading.rb'

gsub_file 'config/database.yml', /^test:.*\n/, "test: &test\n"
gsub_file 'config/database.yml',
          /\z/,
          "\ncucumber:\n  <<: *test\n  database: db/cucumber.sqlite3"
gsub_file(
  'config/database.yml',
  /\z/,
  "\ncucumber_with_reloading:\n  <<: *test\n  database: db/cucumber.sqlite3"
)

if File.exist?('config/secrets.yml')
  require 'securerandom'
  cucumber_secret = SecureRandom.hex(64)
  gsub_file 'config/secrets.yml',
            /\z/,
            "\ncucumber:\n  secret_key_base: #{cucumber_secret}"
end

base_record = if Rails::VERSION::MAJOR >= 5
                'ApplicationRecord'
              else
                'ActiveRecord::Base'
              end

# Generate some test models
generate :model, 'post title:string body:text published_at:datetime author_id:integer category_id:integer'
post_model_setup = if Rails::VERSION::MAJOR >= 5
                     <<-MODEL
  belongs_to :author, class_name: 'User'
  belongs_to :category, optional: true
  accepts_nested_attributes_for :author
MODEL
                   else
                     <<-MODEL
  belongs_to :author, class_name: 'User'
  belongs_to :category
  accepts_nested_attributes_for :author
MODEL
                   end
inject_into_file 'app/models/post.rb',
                 post_model_setup,
                 after: "class Post < #{base_record}\n"

generate :model, 'user type:string first_name:string last_name:string username:string age:integer'
inject_into_file 'app/models/user.rb',
                 "  has_many :posts, foreign_key: 'author_id'\n",
                 after: "class User < #{base_record}\n"

generate :model, 'publisher --migration=false --parent=User'

generate :model, 'category name:string description:text'
inject_into_file 'app/models/category.rb',
                 "  has_many :posts\n  accepts_nested_attributes_for :posts\n",
                 after: "class Category < #{base_record}\n"

generate :model, 'store name:string'

# Generate a model with string ids
generate :model, 'tag name:string'
gsub_file(
  Dir['db/migrate/*_create_tags.rb'][0],
  /\:tags\sdo\s.*/,
  ":tags, id: false, primary_key: :id do |t|\n\t\t\tt.string :id\n"
)
id_model_setup = <<-MODEL
  self.primary_key = :id
  before_create :set_id

  private
  def set_id
    self.id = 8.times.inject('') do |s,e|
      s << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr
    end
  end
MODEL

inject_into_file 'app/models/tag.rb',
                 id_model_setup,
                 after: "class Tag < #{base_record}\n"

# Configure default_url_options in test environment
inject_into_file(
  'config/environments/test.rb',
  "  config.action_mailer.default_url_options = { host: 'example.com' }\n",
  after: "config.cache_classes = true\n"
)

# Add our local Active Admin to the load path
lib_path = File.expand_path('../../../lib/activeadmin-xls', __FILE__)
inject_into_file 'config/environment.rb',
                 "\nrequire '#{lib_path}'\n",
                 after: "require File.expand_path('../application', __FILE__)"

# Add some translations
append_file 'config/locales/en.yml',
            File.read(File.expand_path('../templates/en.yml', __FILE__))

# Add predefined admin resources
directory File.expand_path('../templates/admin', __FILE__), 'app/admin'

run 'rm Gemfile'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

generate :'active_admin:install'

run 'rm -r test'
run 'rm -r spec'

inject_into_file 'config/initializers/active_admin.rb',
                 "  config.download_links = %i[csv xml json xls]\n",
                 after: "  # == Download Links\n"

# Setup a root path for devise
route "root to: 'admin/dashboard#index'"

rake 'db:migrate'
rake 'db:test:prepare'
run '/usr/bin/env RAILS_ENV=cucumber rake db:migrate'
