//
//  P2PInterface.swift
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

public final class JSONListener<StreamType: ServerStream>: CustomServer {
	public let stream: StreamType
	public var isClosed: Bool
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
		self.isClosed = false
		self.listenMax = listenMax
	}
	
	private let queue = DispatchQueue(label: "com.vkoskiv.peerserver",
	                                  qos: .userInteractive,
	                                  attributes: .concurrent)
	
	public func start() throws {
		try stream.bind()
		self.isClosed = false
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
		var buffer = Bytes(repeating: 0, count: 2048)
		
		//Close stream after handling
		defer {
			try? stream.close()
		}
		
		var keepAlive = false
		main: repeat {
			var json: JSON?
			
			while json == nil {
				let read = try stream.read(max: buffer.count, into: &buffer)
				guard read > 0 else {
					break main
				}
				json = try JSON(bytes: buffer)
			}
			
			guard let jsonData = json else {
				print("Could not parse JSON from stream")
				//FIXME: Throw
				break
			}
			
			//handle
			state.p2pProtocol.received(json: jsonData, peer: state.peerForHostname(host: stream.hostname))
			
			//And close stream
			self.isClosed = true
			
		} while keepAlive && !self.isClosed
	}

}

class myResponder: Responder {
	func respond(to request: Request) throws -> Response {
		return Response(redirect: "")
	}
}
