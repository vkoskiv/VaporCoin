//
//  Client.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation
import Vapor

class Client: Hashable {
	var pubKey: String
	var socket: WebSocket? = nil
	
	var currentDifficulty: Int64
	
	
	init() {
		self.pubKey = ""
		self.currentDifficulty = 1
	}
	
	var hashValue: Int {
		return self.pubKey.hashValue
	}
}

func ==(lhs: Client, rhs: Client) -> Bool {
	return lhs.pubKey.hashValue == rhs.pubKey.hashValue
}
