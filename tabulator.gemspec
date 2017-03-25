# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tabulator/version'

Gem::Specification.new do |spec|
  spec.name          = "tabulator"
  spec.version       = Tabulator::VERSION
  spec.authors       = ["chapuzzo"]
  spec.email         = ["luismax@gmail.com"]

  spec.summary       = %q{Reads tabulated data from Google Spreadsheets}
  spec.description   = %q{Reads tabulated data from Google Spreadsheets}
  spec.homepage      = "https://github.com/chapuzzo/tabulator"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "google_drive", "~> 2.1.2"
  spec.add_dependency "i18n", "~> 0.7.0"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
