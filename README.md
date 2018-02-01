<p align="center">
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://travis-ci.org/vapor/api-template">
    	<img src="https://travis-ci.org/vapor/api-template.svg?branch=master" alt="Build Status">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-3.1-brightgreen.svg" alt="Swift 3.1">
    </a>
</center>

## Synopsis

Vaporcoin is a simple blockchain ledger implementation, built with Vapor.

## Goals

Functional, simple and easy to understand implementation that favors learning over robust security and usability. This is not intended to be an 'altcoin'

## Specifications

Blocks:
- Block time 60 seconds
- 6000 transactions per block (Effective 100 txns/s rate)
- Block difficulty updated every 60 blocks (hourly)
- Block reward 50 full units/block (1 unit = 100 000 000 sub-units)
- Block reward halved every 4 years (2 102 400 blocks at 525 600 blocks per year)
- Total amount of full units will be roughly ~209 829 375

Transactions:
- Simplified Bitcoin-style transactions, UTXO (No scripting capability)
- ECDSA signatures

Proof of Work (PoW) algorithm:

- Simplified Bitcoin-style. SHA256 hash of block header

Block header: 
- Previous hash
- Merkle root of transactions in block
- UNIX timestamp
- Target difficulty
- Nonce (32 bit)

## TODO

- JSON WebSocket p2p communication / Incomplete
- Peer discovery
- Locally hosted web interface to send and receive transactions, change settings and monitor blockchain status.
- Miner / Implemented, needs work
- Fractional difficulty adjustment (Swift can't deal with 256bit uints)
- Database logic
- Proper node syncing
- ECDSA Signatures, key management (Wallet.swift)
- UTXO Transactions
- Establish consensus

## Getting started

    brew install vapor/tap/vapor
    
    In project root directory:
    vapor update
    vapor build 
    vapor run

	If you are using Xcode, make sure to select `My Mac` as target, and select the `Run` scheme.

## Difficulty Factor
   To mine a block, you can lower the diffBis amount in Droplet+Setup.swift line 17:
  
	let miner = Miner(coinbase: "coinbaseAddressNotImplementedYet", diffBits: 20, threadCount: 4)

## Tips
   Get me some coffee:

	ETH: 0x1e8e9c1a1b71ff88829b962cfa7190d074343b37
	LTC: LZc2QcyZGuhHF18s96VAUPpByZq2S8yCsj
	ZEC: t1UukAm25iRLTyTQfhX6WfRBzMjp8UCmy4a
