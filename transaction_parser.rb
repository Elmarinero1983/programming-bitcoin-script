## Bitcoin Transaction Parser & Validator
## Educational tool for understanding Bitcoin transaction structure

require 'pp'
require 'ecdsa'
require 'digest'

## Helper class for parsing Bitcoin transaction hex data

class BitcoinTransaction
  attr_reader :tx_hex, :version, :inputs, :outputs, :locktime
  
  def initialize(tx_hex)
    @tx_hex = tx_hex
    @bytes = [tx_hex].pack('H*')
    @cursor = 0
    parse_transaction
  end
  
  private
  
  def read_bytes(count)
    result = @bytes[@cursor...@cursor + count]
    @cursor += count
    result
  end
  
  def read_varint
    first_byte = read_bytes(1).unpack('C')[0]
    case first_byte
    when 0..252
      first_byte
    when 253
      read_bytes(2).unpack('v')[0]  # little-endian short
    when 254
      read_bytes(4).unpack('V')[0]  # little-endian int
    when 255
      read_bytes(8).unpack('Q<')[0] # little-endian long
    end
  end
  
  def parse_transaction
    @version = read_bytes(4).unpack('V')[0]
    
    # Parse inputs
    input_count = read_varint
    @inputs = []
    input_count.times do |i|
      @inputs << parse_input(i)
    end
    
    # Parse outputs
    output_count = read_varint
    @outputs = []
    output_count.times do |i|
      @outputs << parse_output(i)
    end
    
    @locktime = read_bytes(4).unpack('V')[0]
  end
  
  def parse_input(index)
    prev_txid = read_bytes(32).unpack('H*')[0]
    prev_output_index = read_bytes(4).unpack('V')[0]
    script_length = read_varint
    script_sig = read_bytes(script_length).unpack('H*')[0]
    sequence = read_bytes(4).unpack('V')[0]
    
    {
      index: index,
      previous_txid: prev_txid,
      previous_index: prev_output_index,
      script_sig: script_sig,
      sequence: sequence,
      script_length: script_length
    }
  end
  
  def parse_output(index)
    value = read_bytes(8).unpack('Q<')[0]  # satoshis (little-endian)
    script_length = read_varint
    script_pubkey = read_bytes(script_length).unpack('H*')[0]
    
    {
      index: index,
      value: value,
      value_btc: value / 100_000_000.0,
      script_pubkey: script_pubkey,
      script_length: script_length
    }
  end
  
  public
  
  def display
    puts "╔════════════════════════════════════════════════════════════╗"
    puts "║         BITCOIN TRANSACTION PARSER & VALIDATOR             ║"
    puts "╚════════════════════════════════════════════════════════════╝"
    puts ""
    
    puts "📋 TRANSACTION METADATA"
    puts "─" * 60
    puts "Version:        #{@version}"
    puts "Locktime:       #{@locktime}"
    puts "Input Count:    #{@inputs.length}"
    puts "Output Count:   #{@outputs.length}"
    puts ""
    
    puts "📥 INPUTS"
    puts "─" * 60
    @inputs.each do |input|
      puts "\nInput ##{input[:index]}"
      puts "  Previous TXID:  #{input[:previous_txid]}"
      puts "  Previous Index: #{input[:previous_index]}"
      puts "  Script Length:  #{input[:script_length]} bytes"
      puts "  ScriptSig:      #{input[:script_sig][0..64]}..." if input[:script_sig].length > 64
      puts "  Sequence:       #{input[:sequence]}"
    end
    puts ""
    
    puts "📤 OUTPUTS"
    puts "─" * 60
    @outputs.each do |output|
      puts "\nOutput ##{output[:index]}"
      puts "  Value:          #{output[:value_btc]} BTC (#{output[:value]} satoshis)"
      puts "  Script Length:  #{output[:script_length]} bytes"
      puts "  ScriptPubKey:   #{output[:script_pubkey][0..64]}..." if output[:script_pubkey].length > 64
    end
    puts ""
    
    display_script_analysis
  end
  
  def display_script_analysis
    puts "🔍 SCRIPT ANALYSIS"
    puts "─" * 60
    
    @inputs.each do |input|
      puts "\nInput ##{input[:index]} Script Analysis:"
      analyze_script(input[:script_sig], "ScriptSig")
    end
    
    @outputs.each do |output|
      puts "\nOutput ##{output[:index]} Script Analysis:"
      analyze_script(output[:script_pubkey], "ScriptPubKey")
    end
    puts ""
  end
  
  def analyze_script(script_hex, script_type)
    script_bytes = [script_hex].pack('H*')
    puts "  Type:           #{script_type}"
    puts "  Hex:            #{script_hex[0..64]}..."
    puts "  Length:         #{script_bytes.length} bytes"
    
    # Identify script type
    case script_hex.length
    when 0
      puts "  Pattern:        Empty (OP_0)"
    when 88
      puts "  Pattern:        ECDSA Signature (likely P2PK or P2PKH)"
    when 130
      puts "  Pattern:        Compressed Public Key (P2PK)"
    else
      puts "  Pattern:        Unknown/Complex"
    end
  end
  
  def to_json_summary
    {
      version: @version,
      locktime: @locktime,
      inputs_count: @inputs.length,
      outputs_count: @outputs.length,
      total_output_btc: @outputs.sum { |o| o[:value_btc] },
      inputs: @inputs.map { |i| { txid: i[:previous_txid], index: i[:previous_index] } },
      outputs: @outputs.map { |o| { value_btc: o[:value_btc], script_length: o[:script_length] } }
    }
  end
end


## EXAMPLE: Parse the provided transaction

if __FILE__ == $0
  # Real Bitcoin transaction (segwit)
  tx_hex = "010000000177687aea3d77ee774c0b11d5cf4d1aca83a061447b5f124a605a1777425d3cae010000006b4830450221009e9b9338590afa0d9c7b192a6db4be8490658b3ae0d27d368e3566a8282408a302202211d042b8497a6073c1a0c47f31a1e3594b6b2d247c34807f2968fb7c387ce9012102759894166844292f690d9bdc29b38fa47079383f071c8720f4a35a55fec4f8a4fdffffff02000000000000000016001448cb0e6a5e8bba4ca3cbec249df416bd5497f50a006889090000000016001448cb0e6a5e8bba4ca3cbec249df416bd5497f50a6b660e00"
  
  begin
    tx = BitcoinTransaction.new(tx_hex)
    tx.display
    
    puts "📊 JSON SUMMARY"
    puts "─" * 60
    pp tx.to_json_summary
    
  rescue => e
    puts "❌ Error parsing transaction: #{e.message}"
    puts e.backtrace.first(5)
  end
end
