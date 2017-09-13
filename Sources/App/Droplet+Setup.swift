@_exported import Vapor
import Foundation

let state = State()

extension Droplet {
    public func setup() throws {
        try setupRoutes()
		
		//TODO: Move all this to setupRoutes
		
		//For now init state by reading value from there.
		print("BlockChain count: \(state.blockChain.count)")
		
		//Set up routes
		get("peers") { req in
			return "\(state.blockChain.count)"
		}
		
		post("addPeer") { req in
			return "Send a new peer here so I can add it!"
		}
		
		//Set up webSockets
		
		//Special WebSocket for a miner connection
		socket("miner") { message, webSocket in
			webSocket.onText = { ws, text in
				print("Miner msg: " + text)
			}
		}
		
		socket("p2p") { message, webSocket in
			webSocket.onText = { ws, text in
				print("Received message: " + text)
				let json = try JSON(bytes: Array(text.utf8))
				state.p2pProtocol.received(json: json)
			}
			
			func test() throws {
				//TODO
			}
		}
    }
}
