## p2pk - Pay-to-pubkey bitcoin (standard) script
## With real ECDSA signature verification

require 'pp'
require 'ecdsa'
require 'digest'

## Bitcoin crypto helper

class Bitcoin
  # Verify a signature using ECDSA Secp256k1 (Bitcoin's curve)
  # 
  # Args:
  #   message: The data that was signed (string or hash)
  #   sig: The signature (ECDSA::Signature object)
  #   pubkey: The public key point (ECDSA::Point object)
  #
  # Returns: true if signature is valid, false otherwise
  def self.checksig( message, sig, pubkey )
    begin
      group = ECDSA::Group::Secp256k1
      
      # Hash the message with SHA256 (Bitcoin standard)
      message_hash = Digest::SHA256.digest( message )
      
      # Convert hash to integer for verification
      z = message_hash.unpack('H*')[0].to_i(16)
      
      # Verify the signature
      ECDSA.verify( group, pubkey, sig, z )
    rescue => e
      puts "Verification error: #{e.message}"
      false
    end
  end
  
  # Sign a message with a private key
  #
  # Args:
  #   message: The data to sign (string)
  #   privatekey: The private key (integer)
  #
  # Returns: ECDSA::Signature object
  def self.sign( message, privatekey )
    group = ECDSA::Group::Secp256k1
    
    # Hash the message with SHA256
    message_hash = Digest::SHA256.digest( message )
    
    # Convert hash to integer for signing
    z = message_hash.unpack('H*')[0].to_i(16)
    
    # Sign with ECDSA
    ECDSA.sign( group, privatekey, z )
  end
end


## A simple stack machine

def op_checksig( stack, message = nil )
  raise "Message required for signature verification" if message.nil?
  
  pubkey = stack.pop
  sig    = stack.pop
  
  if Bitcoin.checksig( message, sig, pubkey )
    stack.push( 1 )
  else
    stack.push( 0 )
  end
end


## Let's run!

puts "=== Bitcoin Pay-to-PubKey (P2PK) Script Execution ==="
puts ""

# Generate a key pair
group = ECDSA::Group::Secp256k1
privatekey = 12345  # Private key (keep secret!)
pubkey = group.generator.multiply_by_scalar( privatekey )

puts "1. Key Generation"
puts "   Private Key: #{privatekey}"
puts "   Public Key (x): #{pubkey.x}"
puts "   Public Key (y): #{pubkey.y}"
puts ""

# The message/transaction data to sign
message = "Send 1 BTC to Alice"
puts "2. Message to sign: '#{message}'"
puts ""

# Sign the message (off-chain, by the spender)
sig = Bitcoin.sign( message, privatekey )
puts "3. Signature created"
puts "   R: #{sig.r}"
puts "   S: #{sig.s}"
puts ""

# Now execute the script on-chain
puts "4. Script Execution (on-chain validation)"
puts ""

stack = []

# ScriptSig (input/unlock part - pushed by spender)
puts "   I) ScriptSig (unlock):"
pp stack.push( sig )
puts ""

# ScriptPubKey (output/lock part - checked by network)
puts "   II) ScriptPubKey (lock):"
pp stack.push( pubkey )
puts ""

# Execute OP_CHECKSIG
puts "   III) Execute OP_CHECKSIG:"
pp op_checksig( stack, message )
puts ""

# Result
result = stack.pop
puts "5. Validation Result: #{result == 1 ? '✓ VALID' : '✗ INVALID'}"
if result == 1
  puts "   Transaction is VALID - signature verified successfully!"
else
  puts "   Transaction is INVALID - signature verification failed!"
end
