//
//  JSONClient.swift
//  App
//
//  Created by Valtteri Koskivuori on 18/09/2017.
//

//NOT USED FOR NOW

import libc
import Vapor
import Transport
import Dispatch
import Sockets
import TLS //May not be needed

/*public enum JSONClientError: Swift.Error {
	case invalidRequestHost
	case invalidRequestPort
	case unableToConnect
	case missingHost
}

public protocol CustomClient: InternetStream { }
public typealias TCPJSONClient = JSONClient<TCPInternetSocket>

public final class JSONClient<StreamType: ClientStream>: CustomClient {
	public let stream: StreamType
	
	public var scheme: String {
		return stream.scheme
	}
	
	public var hostname: String {
		return stream.hostname
	}
	
	public var port: Port {
		return stream.port
	}
	
	var buffer: Bytes
	
	public init(_ stream: StreamType) throws {
		self.stream = stream
		try stream.connect()
		buffer = Bytes(repeating: 0, count: 2048)
	}
	
	deinit {
		try? stream.close()
	}
	
	public func sendRequest(json: JSON) throws -> JSON {
		
		guard !stream.isClosed else {
			throw JSONClientError.unableToConnect
		}
		
		while true {
			buffer = try json.makeBytes()
			guard buffer.count > 0 else {
				break
			}
			let written = try stream.write(max: buffer.count, from: buffer)
			guard written == buffer.count else {
				throw StreamError.closed
			}
		}
		
		let jsonParser = JSONRPCParser()
		
		var jsonResponse: JSON?
		while jsonResponse == nil {
			let read = try stream.read(max: jsonParser.buffer.count, into: &jsonParser.buffer)
			guard read > 0 else {
				break
			}
			jsonResponse = jsonParser.parse()
		}
		return jsonResponse!
	}
}*/
