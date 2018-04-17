//
//  Transaction.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 11/09/2017.
//

import Vapor
import Foundation

public enum transactionType {
	case coinbase //Special, miner reward
	case normal   //Regular utxo value transaction
	case data     //Arbitrary data?
}

//TODO: Possibly put value, from, recipient into a payload struct and support other types of txn
//hash, sig and pubkey should exist in all transactions anyway

class Transaction: Equatable {

	// 100,000,000 = 1.0 VaporCoins (8 decimal places)

	var value: Int64

	var from: Data
	var recipient: Data

	var txnType: transactionType

	var txnHash: Data { //Hash of transaction
		return self.encoded.sha256
	}

	var encoded: Data {
		return Data(from: value) + from + recipient + Data(from: txnType)
	}

	//These are both optional - Coinbase transactions don't need em
	var senderSig: Data? //txnHash signed with privKey
	var senderPubKey: AsymmetricKey? //The key that can "decrypt" senderSig

	//TODO - Ripemd160 of pubkey
	var senderAddress: Data? {
		return Data()
	}

	init(value: Int64 = 0,
		 from: Data = Data(),
		 recipient: Data = Data(),
		 txnType: transactionType = .normal,
		 senderSig: Data? = Data(),
		 senderPubKey: AsymmetricKey? = nil
		) {
		self.value = value

		self.from = from
		self.recipient = recipient

		self.txnType = txnType

		self.senderSig = senderSig
		self.senderPubKey = senderPubKey
	}

	func newCoinbase(address: Wallet) -> Transaction {
		//Get current block reward from Consensus protocol
		let br = currentBlockReward()

		guard let address = address.address else {
			print("No address for coinbase!")
			return Transaction()
		}

		let txn = Transaction(value: br,
							  from: Data(),
							  recipient: address,
							  txnType: .coinbase,
							  senderSig: nil,
							  senderPubKey: nil)
		return txn
	}

	func newTranscation(source: Wallet, dest: Wallet, input: Int64, output: Int64) -> Transaction {
		//TODO

		//Get valid inputs
		//Construct valid outputs
		//Construct transaction

		return Transaction()
	}

	//TODO: Move to BlockChain.swift
	func getInputs(forOwner: Wallet, forAmount: Int64) -> [Transaction] {
		//Get inputs
		//Then map filter out ones that have been spent
		//for tx in block.txns {
		//	  state.memPool = state.memPool.filter { $0 != tx}
		//}

		//Then take required amount starting from oldest

		//let allAvailableTransactions = state.blockChain.filter { $0.txns.filter { $0.outputs.filter { $0.recipient.address == forOwner.address } } }

		var allAvailableTransactions: [Transaction] = []

		//Get all past input transactions of the sender
		/*for block in state.blockChain {
			for txn in block.txns {
				if txn.recipient == forOwner.address {
					allAvailableTransactions.append(txn)
				}
			}
		}

		//Get all spent transactions
		for block in state.blockChain {
			for txn in block.txns {
				if txn.senderAddress == forOwner.address {

				}
			}
		}*/

		/*for block in state.blockChain {
		for txn in block.txns {
		if txn.senderPubKey == forOwner.pubKey {

		}
		}
		}*/

		return [Transaction()]
	}

	//TODO: Move to BlockChain.swift
	func getTransactionWith(hash: Data) -> Transaction {
		/*for block in state.blockChain {
			for txn in block.txns {
				if txn.txnHash == hash {
					return txn
				}
			}
		}*/
		print("no txn found with \(hash)")
		return Transaction()
	}

	static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
		return lhs.txnHash == rhs.txnHash
	}
}

