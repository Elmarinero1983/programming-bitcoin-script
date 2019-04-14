# Programming Bitcoin Script Transaction (Crypto) Contracts Step-by-Step

_Let's start with building your own bitcoin stack machine from zero / scratch and let's run your own bitcoin ops (operations)..._


Did you know? Every (yes, every) bitcoin transaction (payment) runs
a contract script (one half coming from the "output" or "lock" transaction and the
other half coming from the "input" or "unlock" transaction).
The programming language is called simply (bitcoin) script.

> Bitcoin uses a scripting system for transactions.
> Forth-like, Script is simple, stack-based, and processed from left to right.
> It is intentionally not Turing-complete, with no loops.
>
> (Source: [Script @ Bitcoin Wiki](https://en.bitcoin.it/wiki/Script))


First impression. Adding 2+2 in Bitcoin Script starting from zero / scratch:

``` ruby
## A simple stack machine
def op_add( stack )
  left  = stack.pop
  right = stack.pop
  stack.push( left + right )
end

def op_2( stack )
  stack.push( 2 )
end

## Let's run!

stack = []
op_2( stack )     #=> stack = [2]
op_2( stack )     #=> stack = [2,2]
op_add( stack )   #=> stack = [4]
```

(Source: [`stackmachine_add.rb`](stackmachine_add.rb))



Yes, that's all the magic! You have built your own stack machine with
two operations / ops, that is, `op_add` and `op_2`.

The `op_2` operation pushes the number `2` onto the stack.
The `op_add` operation pops the top two numbers from the stack
and pushes the result onto the stack.  


Aside - What's a Stack? Push 'n' Pop

A stack is a last-in first-out (LIFO) data structure. Use `push`
to add an element to the top of the stack and use `pop`
to remove the top element from the stack.
Example:

``` ruby
stack = []                   #=> []
stack.empty?                 #=> true

stack.push( 1 )              #=> [1]
stack.empty?                 #=> false
stack.push( 2 )              #=> [1, 2]
stack.push( 3 )              #=> [1, 2, 3]
stack.push( "<signature>" )  #=> [1, 2, 3, "<signature>"]
stack.push( "<pubkey>")      #=> [1, 2, 3, "<signature>", "<pubkey>"]

stack.pop                    #=> "<pubkey>"
stack                        #=> [1, 2, 3, "<signature>"]
stack.pop                    #=> "<signature>"
stack                        #=> [1, 2, 3]

stack.push( 4 )              #=> [1, 2, 3, 4]
stack.push( 5 )              #=> [1, 2, 3, 4, 5]

stack.pop                    #=> 5
stack                        #=> [1, 2, 3, 4]
stack.pop                    #=> 4
stack                        #=> [1, 2, 3]
stack.pop                    #=> 3
stack                        #=> [1, 2]
stack.pop                    #=> 2
stack                        #=> [1]
stack.empty?                 #=> false
stack.pop                    #=> 1
stack                        #=> []
stack.empty?                 #=> true
stack.pop                    #=> nil
```

(Source: [`stack.rb`](stack.rb))



Unlock+Lock / Input+Output / ScriptSig+ScriptPubKey

In "real world" bitcoin the script has two parts / halves in two transactions
that get combined.
The "lock" or "output" or "ScriptPubKey" script
that locks the "unspent transaction output (UTXO)"
and the "unlock" or "input" or "ScriptSig" script that unlocks
the bitcoins.


Anyone Can Spend (Unlock) the Outputs (Bitcoins)

The bitcoins are yours if the bitcoins haven't been spent yet -
see blockchain and how it solves the double-spending problem :-) -
AND if the script returns with true, that is, `1` is on top of the stack.

``` ruby
## A simple stack machine
def op_true( stack )
  stack.push( 1 )
end

## Let's run!

stack = []
##  I) ScriptSig (input/unlock) part
op_true( stack )  #=> stack = [1]

## II) ScriptPubKey (output/lock) part
##     <Empty>
```

(Source: [`stackmachine_anyone.rb`](stackmachine_anyone.rb))


Bingo! Yes, that's all the magic!
The `op_true` operation pushes the number `1`, that is, `true` onto the stack.

The "official" bitcoin script notation reads:

```
ScriptSig (input):    OP_TRUE
ScriptPubKey:         (empty)
```

Now let's split the adding `2+2` script into a two part puzzle,
that is, `?+2=4`
or into `ScriptSig` and `ScriptPubKey`.
If you know the answer you can "unlock" the bounty,
that is, the bitcoin are yours!
Here's the challenge:

``` ruby
## A simple stack machine
def op_add( stack )
  left  = stack.pop
  right = stack.pop
  stack.push( left + right )
end

def op_2( stack )
  stack.push( 2 )
end

def op_4( stack )
  stack.push( 4 )
end

def op_equal( stack )
  left  = stack.pop
  right = stack.pop
  stack.push( left == right ? 1 : 0 )
end

## Let's run!

stack = []
##  I) ScriptSig (input/unlock) part
##     FIX!!! - add your "unlock" stack operation / operations here

## II) ScriptPubKey (output/lock) part
op_2( stack )      #=> stack = [?, 2]
op_add( stack )    #=> stack = [4]
op_4( stack )      #=> stack = [4,4]
op_equal( stack )  #=> stack = [1]
```

(Source: [`stackmachine_puzzle.rb`](stackmachine_puzzle.rb))




The "official" bitcoin script notation reads:

```
ScriptSig (input):    ?
ScriptPubKey:         OP_2 OP_ADD OP_4 OP_EQUAL
```


If you check all Bitcoin script operations -
the following ops should no longer be a mystery:

Constants

|Word | Opcode |Hex | Input | Output | Description|
|-----|--------|----|-------|--------|------------|
| OP_0, OP_FALSE |  0  |  0x00 | Nothing. | (empty value) |  An empty array of bytes is pushed onto the stack. (This is not a no-op: an item is added to the stack.) |
| OP_1, OP_TRUE  | 81  | 0x51  | Nothing. | 1 | The number 1 is pushed onto the stack. |
| OP_2-OP_16 | 82-96 |  0x52-0x60  | Nothing. |  2-16 |  The number in the word name (2-16) is pushed onto the stack. |

Bitwise logic

|Word | Opcode |Hex | Input | Output | Description|
|-----|--------|----|-------|--------|------------|
| OP_EQUAL | 135  | 0x87 | x1 x2  | True / false |  Returns 1 if the inputs are exactly equal, 0 otherwise. |

Arithmetic

|Word | Opcode |Hex | Input | Output | Description|
|-----|--------|----|-------|--------|------------|
| OP_ADD |  147  | 0x93  | a b | out  | a is added to b. |
| OP_MUL |  149  | 0x95  | a b | out  | a is multiplied by b. **disabled.** |
| OP_DIV |  150  | 0x96  | a b | out  | a is divided by b. **disabled.** |



Trivia Corner: Did you know? The `OP_MUL` for multiplications (e.g. `2*2`)
has been banned, that is, disabled!  Why?
Because of security concerns, that is, fear of stack overflows.
What about `OP_DIV` for divisions (e.g. `4/2`)?  Don't ask!
Ask who's protecting you from stack underflows?
So what's left for programming - not much really other than checking
signatures and timelocks :-).



## Standard Scripts

You don't have to start from zero / scratch.
Bitcoin has many standard script templates.
The most important include:


| Short Name | Long Name  |
|------------|------------|
| p2pk   | Pay-to-pubkey     |
| p2pkh  | Pay-to-pubkey-hash |
| p2sh   | Pay-to-script-hash  |

Standard Scripts with SegWit (Segregated Witness)

| Short Name | Long Name  |
|------------|------------|
| p2wpkh | Pay-to-witness-pubkey-hash  |
| p2wsh  | Pay-to-witness-script-hash  |



## p2pk - Pay-to-pubkey

Pay-to-pubkey (p2pk) is the simplest standard script
and was used in the early days
including by Satoshi Nakamoto (the pseudonymous Bitcoin founder).

Bitcoin Trivia:

> As initially the sole and subsequently the predominant miner,
> Nakamoto was awarded bitcoin at genesis and for 10 days afterwards.
> Except for test transactions these remain unspent since mid January 2009.
> The public bitcoin transaction log shows that Nakamoto's known addresses contain
> roughly one million bitcoins. At bitcoin's peak in December 2017,
> this was worth over US$19 billion,
> making Nakamoto possibly the 44th richest person in the world at the time.
>
> (Source: [Satoshi Nakamoto @ Wikipedia](https://en.wikipedia.org/wiki/Satoshi_Nakamoto))


The one million bitcoins are yours if the pay-to-pubkey (p2pk) script
returns with true, that is, `1` is on top of the stack.
The only input you need to unlock the the fortune is the signature. Are you Satoshi?
Let's try:


``` ruby
## Bitcoin crypto helper

class Bitcoin
  def self.checksig( sig, pubkey )
    ## "crypto" magic here
    ##  for testing always return false for now; sorry
    false
  end
end  


## A simple stack machine

def op_checksig( stack )
  pubkey = stack.pop
  sig    = stack.pop
  if Bitcoin.checksig( sig, pubkey )
    stack.push( 1 )
  else
    stack.push( 0 )
  end
end

## Let's run!

stack = []
##  I) ScriptSig (input/unlock) part
stack.push( "<sig>" )   #=> stack = ["<sig>"]

## II) ScriptPubKey (output/lock) part
stack.push( "<pubkey")  #=> stack = ["<sig>", "<pubkey>" ]
op_checksig( stack )    #=> stack = [0]
```

(Source: [`pay-to-pubkey.rb`](pay-to-pubkey.rb))

Bingo! Yes, that's all the magic!
The `op_checksig` operation pops two elements from
the stack, that is, the public key (pubkey)
and the signature (sig) and
if the elliptic curve crypto validates the signature (from the input/unlock transaction)
using the public key (from the the output/lock transaction)
than the fortune is yours! If not
the number `0`, that is, `false` gets pushed onto the stack
and you're out of luck. Sorry.

The "official" bitcoin script notation reads:

```
ScriptSig (input): <sig>
ScriptPubKey:      <pubKey> OP_CHECKSIG
```

Note: Can you guess where the input / unlock part got its ScriptSig name
and where the output / lock part got its ScriptPubKey name?
Yes, from the pay-to-pubkey script.

So what does a "real world" public key (pubkey) look like?
In the early days Satoshi Nakamoto
used the uncompressed SEC (Standards for Efficient Cryptography) format
for the public key that results
in 65 raw bytes.
Bitcoin uses elliptic curve
cryptography and the public key is a coordinate / point (x,y) on
the curve where x and y are each 256-bit numbers.


To be continued ...




## Resources

Articles

- [Bitcoin Script @ Bitcoin Wiki](https://en.bitcoin.it/wiki/Script)
- [Script - A mini programming language @ Learn Me a Bitcoin](http://learnmeabitcoin.com/glossary/script)
- [Opcodes @ Bitcoin Developer Reference](https://bitcoin.org/en/developer-reference#opcodes)

Books / Series

- [A developer-oriented series about Bitcoin](https://davidederosa.com/basic-blockchain-programming/) by Davide De Rosa
  - [The Bitcoin Script language (pt. 1)](https://davidederosa.com/basic-blockchain-programming/bitcoin-script-language-part-one/)
  - [The Bitcoin Script language (pt. 2)](https://davidederosa.com/basic-blockchain-programming/bitcoin-script-language-part-two/)
  - [Standard scripts](https://davidederosa.com/basic-blockchain-programming/standard-scripts/)

<!-- break -->

- [Programming Bitcoin from Scratch](https://github.com/jimmysong/programmingbitcoin) by Jimmy Song
  - [Chapter 6 - Script](https://github.com/jimmysong/programmingbitcoin/blob/master/ch06.asciidoc) - How Script Works • Example Operations • Parsing the Script Fields • Combining the Script Fields • Standard Scripts • p2pk • Problems with p2pk • Solving the Problems with p2pkh • Scripts Can Be Arbitrarily Constructed • Conclusion
  - [Chapter 8 - Pay-to-Script Hash](https://github.com/jimmysong/programmingbitcoin/blob/master/ch08.asciidoc) - Bare Multisig • Coding OP_CHECKMULTISIG • Problems with Bare Multisig • Pay-to-Script-Hash (p2sh) • Coding p2sh • Conclusion
  - [Chapter 13 - Segregated Witness](https://github.com/jimmysong/programmingbitcoin/blob/master/ch13.asciidoc) - Pay-to-Witness-Pubkey-Hash (p2wpkh) • p2wpkh Transactions • p2sh-p2wpkh • Coding p2wpkh and p2sh-p2wpkh • Pay-to-Witness-Script-Hash (p2wsh) • p2sh-p2wsh • Coding p2wsh and p2sh-p2wsh • Other Improvements • Conclusion


Talk Notes

- [Contracts, Contracts, Contracts - Code Your Own (Crypto Blockchain) Contracts w/ Ruby (sruby), Universum & Co](https://github.com/geraldb/talks/blob/master/contracts.md)
  - Genesis - Bitcoin Script
    - Ivy - Higher-Level Bitcoin Script
    - History Corner - Bitcoin - The World's Worst Database for Everything? - Bitcoin Maximalism in Action
  - Turing Complete and the Halting Problem
    - Fees, Fees, Fees - $$$ - There's No Free Lunch



## License

![](https://publicdomainworks.github.io/buttons/zero88x31.png)

The Programming Bitcoin Script Step-by-Step book / guide
is dedicated to the public domain.
Use it as you please with no restrictions whatsoever.
