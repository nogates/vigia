RSpec.describe Vigia::Rspec do

  described_class.include_shared_folders
  described_class.new.start_tests(self)
end
