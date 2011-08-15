$:.push File.expand_path("../lib", __FILE__)
require 'tabletop/version'

Gem::Specification.new do |s|
  s.name = 'tabletop'
  s.version = Tabletop::VERSION
  s.platform = Gem::Platform::RUBY
  s.date = '2011-08-10'
  s.authors = ['Nick Novitski']
  s.email = 'nicknovitski@gmail.com'
  s.homepage = 'http://github.com/njay/tabletop'
  s.summary = 'A Ruby DSL for role-playing games' 
  s.description = 'Tabletop aims to provide a simple way of describing, automating and tracking the tools and tasks involved in "analog" games, determining results from the motions and properties of various dice and chips.'
  s.extra_rdoc_files = [
    'LICENSE',
    'README.markdown',
  ]

  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.7')
  s.rubygems_version = '1.3.7'
  s.specification_version = 3

  ignores = File.readlines(".gitignore").grep(/\S+/).map {|s| s.chomp }
  dotfiles = [".gitignore"]
  
  s.files = Dir["**/*"].reject {|f| File.directory?(f) || ignores.any? {|i| File.fnmatch(i, f) } } + dotfiles
  s.test_files = s.files.grep(/^spec\//)
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
end

