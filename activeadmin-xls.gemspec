require File.expand_path('../lib/active_admin/xls/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'activeadmin-xls'
  s.version = ActiveAdmin::Xls::VERSION
  s.author = 'Todd Hambley'
  s.email = 'thambley@travelleaders.com'
  s.homepage = 'https://github.com/thambley/activeadmin-xls'
  s.platform = Gem::Platform::RUBY
  s.date = Time.now.strftime('%Y-%m-%d')
  s.license = 'MIT'
  s.summary = <<-SUMMARY
  Adds excel (xls) downloads for resources within the Active Admin framework.
  SUMMARY
  s.description = <<-DESC
  This gem provides excel/xls downloads for resources in Active Admin.
  DESC

  git_tracked_files = `git ls-files`.split("\n").sort
  gem_ignored_files = `git ls-files -i -X .gemignore`.split("\n")

  s.files = git_tracked_files - gem_ignored_files

  s.add_runtime_dependency 'activeadmin', '>= 1.0.0'
  s.add_runtime_dependency 'spreadsheet', '~> 1.0'

  s.required_ruby_version = '>= 2.0.0'
  s.require_path = 'lib'
end
