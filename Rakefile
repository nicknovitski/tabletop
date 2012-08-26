require 'rubygems'

begin
  require 'bundler'
rescue LoadError
  $stderr.puts "You must install bundler - run `gem install bundler`"
end

begin
  Bundler.setup
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

gemspec = eval(File.read(Dir["*.gemspec"].first))
desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

desc "Build gem locally"
task :build => :gemspec do
  system "gem build #{gemspec.name}.gemspec"
  FileUtils.mkdir_p "pkg"
  FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", "pkg"
end
 
desc "Install gem locally"
task :install => :build do
  system "gem install pkg/#{gemspec.name}-#{gemspec.version}"
end

desc "Clean automatically generated files"
task :clean do
  FileUtils.rm_rf "pkg"
end

desc "Update master and develop branches on github"
task :github do
  system "git push origin : --tags"
end

desc "Push changes to github and rubygems"
task :publish => :github do
  system "gem push pkg/#{gemspec.name}-#{gemspec.version}.gem"
end