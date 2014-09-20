$:.push File.expand_path("../lib", __FILE__)
require 'tabletop/version'

Gem::Specification.new do |s|
  s.name = 'tabletop'
  s.version = Tabletop::VERSION
  s.platform = Gem::Platform::RUBY
  s.date = '2011-08-10'
  s.authors = ['Nick Novitski']
  s.email = 'nicknovitski@gmail.com'
  s.homepage = 'http://github.com/nicknovitski/tabletop'
  s.summary = 'An RPG and tabletop game library'
  s.description = 'Tabletop aims to provide a simple way of describing, automating and tracking the tools and tasks involved in "analog" games, determining results from the motions and properties of various dice and chips.'
  s.extra_rdoc_files = [
    'LICENSE',
    'README.markdown',
  ]

  ignores = File.readlines(".gitignore").grep(/\S+/).map {|s| s.chomp }
  dotfiles = [".gitignore"]

  s.files = Dir["**/*"].reject {|f| File.directory?(f) || ignores.any? {|i| File.fnmatch(i, f) } } + dotfiles
  s.test_files = s.files.grep(/^spec\//)
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
end

