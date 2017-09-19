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

- JSON TCP interface for peer-to-peer communication / Done, untested
- Peer discovery
- JSON-RPC protocol
- Locally hosted web interface to send and receive transactions, change settings and monitor blockchain status.
- Miner program. Possibly separate process.
