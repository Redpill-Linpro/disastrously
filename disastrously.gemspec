# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lib/app_version"

# Only the first part, not the date, and no dashes.
version = APP_VERSION.to_s.split.first.gsub(/-/, ".")

Gem::Specification.new do |s|
  s.name        = "disastrously"
  s.version     = version
  s.authors     = ["Redpill Linpro AS", "S. Christoffer Eliesen"]
  s.email       = ["disastrously@redpill-linpro.com"]
  s.homepage    = ""
  s.summary     = %q{Disastrously is an Incident Tracker suitable for hosting companies.}
  s.description = s.summary

  s.rubyforge_project = "disastrously"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rake"
  s.add_runtime_dependency "rack",   "~> 1.1.0"
  s.add_runtime_dependency "rails",  "~> 2.3.11"

  s.add_runtime_dependency "pg" # postgresql adapter

  s.add_runtime_dependency "fastercsv", '~> 1.5.4'
  s.add_runtime_dependency "net-ldap"
  s.add_runtime_dependency "rdoc"

  # Exception notification for Rails 2.3:
  s.add_runtime_dependency 'exception_notification', "~> 2.3.0"

  s.add_development_dependency 'rspec',        '~> 1.3.1'
  s.add_development_dependency 'rspec-rails',  '~> 1.3.1'

  #s.add_development_dependency "rcov"

  # For some reason we need version 1.2.3 for pre-Rails 3.
  s.add_development_dependency "factory_girl", "~> 1.2.3"
  s.add_development_dependency "capybara"
end
