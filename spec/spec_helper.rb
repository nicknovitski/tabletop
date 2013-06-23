require 'rspec'
require 'pry'

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

