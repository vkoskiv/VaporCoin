import Vapor

extension Droplet {
    func setupRoutes() throws {
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
				let json = try JSON(bytes: Array(text.utf8))
				state.minerProtocol.received(json: json)
			}
		}
		
		socket("p2p") { message, webSocket in
			var peer: State = State()
			webSocket.onText = { ws, text in
				print("Received message: " + text)
				let json = try JSON(bytes: Array(text.utf8))
				state.p2pProtocol.received(json: json, peer: peer)
			}
		}
        
        try resource("posts", PostController.self)
    }
}
