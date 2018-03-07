#!/usr/bin/env rake
require File.expand_path('../lib/active_admin/xls/version', __FILE__)
require 'rspec/core/rake_task'

desc 'Creates a test rails app for the specs to run against'
task :setup do
  require 'rails/version'
  base_dir = 'spec/rails'
  app_dir = "#{base_dir}/rails-#{Rails::VERSION::STRING}"
  template = 'rails_template_with_data'

  if File.exist? app_dir
    puts "test app #{app_dir} already exists; skipping"
  else
    system "mkdir -p #{base_dir}"
    args = %W[
      -m spec/support/#{template}.rb
      --skip-bundle
      --skip-listen
      --skip-turbolinks
      --skip-test-unit
      --skip-coffee
    ]

    command = ['bundle', 'exec', 'rails', 'new', app_dir, *args].join(' ')
    env = { 'BUNDLE_GEMFILE' => ENV['BUNDLE_GEMFILE'] }
    Bundler.with_clean_env { Kernel.exec(env, command) }
  end
end

RSpec::Core::RakeTask.new
task default: :spec
task test: :spec

desc 'build the gem'
task :build do
  system 'gem build activeadmin-xls.gemspec'
end

desc 'build and release the gem'
task release: :build do
  system "gem push activeadmin-xls-#{ActiveAdmin::Xls::VERSION}.gem"
end
