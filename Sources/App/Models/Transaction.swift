//
//  Transaction.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 11/09/2017.
//

import Vapor
import Foundation

class Address {
	
}

class Transaction {

	enum txType {
		case transaction
		case blockReward
		case dataRecord //Arbitrary data on the blockchain
	}
	
	var type: txType
	// 100,000,000 = 1.0 VaporCoins
	//Difference between inputAmt and outputAmt goes to miner as fee
	//TODO: Make sure output isn't greater than input
	var inputAmount: Int64
	var outputAmount: Int64
	//From and senderpubkey are optional. BlockRewards don't need them.
	var from: Address? = nil
	var senderPubKey: Address? = nil //TODO: Keys and generation
	var senderSignature: Signature
	
	var to: Address
	var hash: Data
	
	
	init() {
		self.type = .transaction
		self.inputAmount = 0
		self.outputAmount = 0
		self.from = Address()
		self.to = Address()
		self.hash = Data()
	}
	
	func newTransaction() -> Transaction {
		return Transaction()
	}
	
	func newBlockReward() -> Transaction {
		return Transaction()
	}
}
