Then(/^I run Vigia$/) do
  Vigia.rspec!
  @stdout.rewind
  @stderr.rewind
  @vigia_stdout = @stdout.read
  @vigia_stderr = @stderr.read
  RSpec.reset
end

Then(/^the output should contain the following:$/) do |text|
  expect(@vigia_stdout).to include(text)
end

Then(/^the total tests line should equal "(.*?)"$/) do |totals_line|
  expect(@vigia_stdout.lines.to_a.last.strip).to eql(totals_line)
end

Then(/^the error output should be empty$/) do
  expect(@vigia_stderr).to be_empty
end


