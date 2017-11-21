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
  s.summary = 'Adds excel (xls) downloads for resources within the Active Admin framework.'
  s.description = <<-DESC
  This gem provides excel/xls downloads for resources in Active Admin.
  DESC
  s.files = `git ls-files`.split("\n").sort
  s.test_files = `git ls-files -- {spec}/*`.split("\n")
  s.test_files = Dir.glob('{spec/**/*}')

  s.add_runtime_dependency 'activeadmin', '~> 1.0'
  s.add_runtime_dependency 'spreadsheet', '~> 1.1'

  s.required_ruby_version = '>= 2.1'
  s.require_path = 'lib'
end
