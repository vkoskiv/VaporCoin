//
//  JSONRPCParser.swift
//  App
//
//  Created by Valtteri Koskivuori on 15/09/2017.
//

import Foundation
import Vapor

//NOT USED FOR NOW

/*public final class JSONRPCParser {
	var buffer: Bytes
	
	public init() {
		buffer = []
	}
	
	public func parse() -> JSON? {
		var response: JSON?
		
		for byte in buffer {
			buffer.append(byte)
			if byte == Byte("}") {
				response = try! JSON(bytes: buffer)
				buffer.removeAll(keepingCapacity: true)
			}
		}
		
		return response
	}
}*/
