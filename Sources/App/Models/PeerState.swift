//
//  PeerClient.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 12/12/2017.
//

import Foundation
import Vapor

class PeerState: Hashable {
	
	var hostName: String
	var id: Int
	var clientVersion: Int
	var clientType: String
	
	init(hostname: String, clientVersion: Int, clientType: String) {
		self.hostName = hostname
		self.clientVersion = clientVersion
		self.clientType = clientType
		//TODO: Proper ID gen + checks
		self.id = 4
	}
	
	var hashValue: Int {
		return self.id
	}
	
	func sendRequest(json: JSON) {
		print("Sending \(json)")
		//Get websocket for this
		let ws = state.peers[self]
		do {
			try ws?.send(json.makeBytes())
		} catch {
			print("Failed sendRequest \(json) to \(self.hostName)")
		}
	}
}

func ==(lhs: PeerState, rhs: PeerState) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
