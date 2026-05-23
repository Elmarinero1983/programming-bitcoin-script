#!/usr/bin/env ruby

## Local Test Runner for Bitcoin Script Examples
## Run all examples locally without GitHub Actions

puts "╔════════════════════════════════════════════════════════════╗"
puts "║     BITCOIN SCRIPT LEARNING PROJECT - LOCAL TEST RUN       ║"
puts "╚════════════════════════════════════════════════════════════╝"
puts ""

examples = [
  { name: "Stack (LIFO Data Structure)", file: "stack.rb" },
  { name: "Public Key Generation (ECDSA)", file: "pubkey.rb" },
  { name: "Pay-to-PubKey (Signature Verification)", file: "pay-to-pubkey.rb" },
  { name: "Transaction Parser & Validator", file: "transaction_parser.rb" }
]

failed = []
passed = []

examples.each_with_index do |example, index|
  puts "┌─ [#{index + 1}/#{examples.length}] #{example[:name]}"
  puts "│  File: #{example[:file]}"
  puts "└─" + "─" * 56
  puts ""
  
  begin
    # Run the script and capture output
    output = `bundle exec ruby #{example[:file]} 2>&1`
    
    if $?.success?
      passed << example[:file]
      puts output
      puts ""
      puts "✅ PASSED"
    else
      failed << example[:file]
      puts output
      puts ""
      puts "❌ FAILED (Exit code: #{$?.exitstatus})"
    end
  rescue => e
    failed << example[:file]
    puts "❌ ERROR: #{e.message}"
  end
  
  puts ""
  puts "─" * 60
  puts ""
end

# Summary
puts "╔════════════════════════════════════════════════════════════╗"
puts "║                      TEST SUMMARY                          ║"
puts "╚════════════════════════════════════════════════════════════╝"
puts ""
puts "✅ Passed: #{passed.length}/#{examples.length}"
passed.each { |f| puts "   • #{f}" }
puts ""

if failed.any?
  puts "❌ Failed: #{failed.length}/#{examples.length}"
  failed.each { |f| puts "   • #{f}" }
  puts ""
  exit 1
else
  puts "🎉 All tests passed successfully!"
  puts ""
  exit 0
end
