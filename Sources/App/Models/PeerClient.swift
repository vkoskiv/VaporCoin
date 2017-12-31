//
//  PeerClient.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 12/12/2017.
//

import Foundation
import Vapor

class PeerClient: Hashable {
	
	var hostName: String
	var id: Int
	
	init(hostname: String) {
		self.hostName = hostname
		//TODO: Proper ID gen + checks
		self.id = 4
	}
	
	var hashValue: Int {
		return self.hashValue
	}
	
	func sendRequest(json: JSON) {
		//Get websocket for this
		let ws = state.peers[self]
		do {
			try ws?.send(json.makeBytes())
		} catch {
			print("Failed sendRequest \(json) to \(self.hostName)")
		}
	}
}

func ==(lhs: PeerClient, rhs: PeerClient) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
