//
//  JSONServer.swift
//  App
//
//  Created by Valtteri Koskivuori on 14/09/2017.
//

import libc
import Vapor
import Transport
import Dispatch
import Sockets
import TLS //May not be needed

public typealias CustomServerErrorHandler = (CustomServerError) -> ()

public enum CustomServerError: Swift.Error {
	case bind(host: String, port: Int, Swift.Error)
	case accept(Swift.Error)
	case respond(Swift.Error)
	case dispatch(Swift.Error)
	case unknown(Swift.Error)
}

public protocol CustomServer: InternetStream {
	func start() throws
}

extension CustomServer {
	public func start() throws {
		try start()
	}
}

//Implement a peer-to-peer TCP/IP socket protocol with peer discovery and async socket handing

//Timeout a peer after 30min of inactivity
public var defaultPeerTimeout: Double = 30

public typealias TCPJSONServer = JSONServer<TCPInternetSocket>

public final class JSONServer<StreamType: ServerStream>: CustomServer {
	public let stream: StreamType
	public let listenMax: Int
	
	public var scheme: String {
		return stream.scheme
	}
	public var hostname: String {
		return stream.hostname
	}
	public var port: Port {
		return stream.port
	}
	
	public init(_ stream: StreamType, listenMax: Int = 128) throws {
		self.stream = stream
		self.listenMax = listenMax
	}
	
	private let queue = DispatchQueue(label: "com.vkoskiv.peerserver",
	                                  qos: .userInteractive,
	                                  attributes: .concurrent)
	
	public func start() throws {
		try stream.bind()
		try stream.listen(max: listenMax)
		
		while true {
			let client: StreamType.Client
			
			do {
				client = try stream.accept()
			} catch {
				print("ClientError")
				continue
			}
			
			queue.async {
				do {
					try self.handleRequest(stream: client)
				} catch {
					print("AsyncError")
				}
			}
		}
	}
	
	private func handleRequest(stream: StreamType.Client) throws {
		try stream.setTimeout(defaultPeerTimeout)
		//var buffer = Bytes(repeating: 0, count: 2048)
		var parser = JSONRPCParser()
		
		//Close stream after handling
		defer {
			try? stream.close()
		}
		
		main: repeat {
			var json: JSON?
			
			while json == nil {
				let read = try stream.read(max: parser.buffer.count, into: &parser.buffer)
				guard read > 0 else {
					break main
				}
				json = parser.parse()
			}
			
			guard let jsonData = json else {
				print("Could not parse JSON from stream")
				//FIXME: Throw
				break
			}
			
			//handle
			let JSONResponse = state.p2pProtocol.received(json: jsonData, from: stream.hostname)
			
			//Serialize and send response
			
			let responseBytes = try JSONResponse.makeBytes()
			
			while true {
				guard responseBytes.count > 0 else {
					break
				}
				let writtenBytes = try stream.write(max: responseBytes.count, from: responseBytes)
				guard writtenBytes == responseBytes.count else {
					print("Error writing to stream")
					break
				}
			}
			
			//And close stream
			try? stream.close()
			
		} while !stream.isClosed
	}
}

extension JSONServer where StreamType == TCPInternetSocket {
	public convenience init(
		scheme: String = "coin",
		hostname: String = "0.0.0.0",
		port: Port = 6001,
		listenMax: Int = 64
		) throws {
		let tcp = try StreamType(scheme: scheme, hostname: hostname, port: port)
		try self.init(tcp, listenMax: listenMax)
	}
}
