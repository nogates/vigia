Then(/^I run Vigia$/) do
  Vigia.rspec!
  @stdout.rewind
  @stderr.rewind
  @vigia_stdout = @stdout.read
  @vigia_stderr = @stderr.read
  RSpec.reset
end

Then(/^the output should contain the following:$/) do |text|
  real_text = text.gsub('{SOURCE_FILE}', Vigia::Rspec.adapter.source_file)
  expect(@vigia_stdout.lines.to_a).to include(*real_text.lines.to_a), -> do
    "Could not find lines: \n #{ (real_text.lines.to_a - @vigia_stdout.lines.to_a).join("\n") }"
  end
end

Then(/^the total tests line should equal "(.*?)"$/) do |totals_line|
  total_time_line   = @vigia_stdout.lines.select { |x| x.start_with?('Finished in ') }.last
  total_output_line = @vigia_stdout.lines.to_a[@vigia_stdout.lines.to_a.index(total_time_line) + 1]
  expect(total_output_line.strip).to eql(totals_line.strip)
end

Then(/^the error output should be empty$/) do
  expect(@vigia_stderr).to be_empty
end


