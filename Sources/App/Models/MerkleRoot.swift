//
//  MerkleRoot.swift
//  App
//
//  Created by Valtteri Koskivuori on 13/09/2017.
//

import Foundation

indirect enum MerkleRoot {
	case Empty
	case Node(hash: Data, data: Data?, left: MerkleRoot, right: MerkleRoot)
	
	init() { self = .Empty }
	
	init(hash: Data) {
		self = MerkleRoot.Node(hash: hash, data: nil, left: .Empty, right: .Empty)
	}
}

extension MerkleRoot {
	
	static func createParent(leftChild: MerkleRoot, rightChild: MerkleRoot) -> MerkleRoot {
		var leftHash: Data = Data()
		var rightHash: Data = Data()
		
		switch leftChild {
		case let .Node(hash, _, _, _):
			leftHash = hash
		case .Empty:
			break
		}
		
		switch rightChild {
		case let .Node(hash, _, _, _):
			rightHash = hash
		case .Empty:
			break
		}
		
		let newHash = (leftHash + rightHash).sha256
		return MerkleRoot.Node(hash: newHash, data: nil, left: leftChild, right: rightChild)
	}
	
	static func buildTree(fromTransactions txns: [Transaction]) -> MerkleRoot {
		var nodeArray = [MerkleRoot]()
		
		for tx in txns {
			nodeArray.append(MerkleRoot(hash: tx.txnHash))
		}
		
		while nodeArray.count != 1 {
			var tmpArr = [MerkleRoot]()
			while nodeArray.count > 0 {
				let leftNode = nodeArray.removeFirst()
				//Dupe the left node if right node isn't found
				let rightNode = nodeArray.count > 0 ? nodeArray.removeFirst() : leftNode
				tmpArr.append(createParent(leftChild: leftNode, rightChild: rightNode))
			}
			nodeArray = tmpArr
		}
		return nodeArray.first!
	}
	
}
