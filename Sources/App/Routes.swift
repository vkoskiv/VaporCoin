import Vapor

/*
This is Vapor's HTTP routing.
We use it for WebSockets, and the local HTTP interface.
*/

extension Droplet {
    func setupRoutes() throws {
		//Set up routes
		get("peers") { req in
			return "\(state.blockChain.depth)"
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
		
		//Socket for light clients
		socket("light") { message, webSocket in
			webSocket.onText = { ws, text in
				
			}
		}
		
		socket("p2p") { message, webSocket in
			webSocket.onText = { ws, text in
				print("Received message: " + text)
				let json = try JSON(bytes: Array(text.utf8))
				let response = state.p2pProtocol.received(json: json)
				do {
					try ws.send(response.makeBytes())
				} catch {
					print("Failed to send reply")
				}
			}
		}
    }
}
