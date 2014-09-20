require 'rspec'

RSpec.configure do |config|
  config.color = true
  config.order = 'random'
  config.tty = true
  config.disable_monkey_patching!
end

