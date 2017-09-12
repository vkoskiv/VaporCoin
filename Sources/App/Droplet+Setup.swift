@_exported import Vapor
import Foundation

let state = State()

let httpPort = 3003
let p2pPort = 6262

extension Droplet {
    public func setup() throws {
        try setupRoutes()
		
		//Set up routes
		get("peers") { req in
			return "test"
		}
		
		post("addPeer") { req in
			return "test"
		}
		
		//Set up webSockets
		socket("p2p") { message, webSocket in
			webSocket.onText = { ws, text in
				print("Received message: " + text)
				let json = try JSON(bytes: Array(text.utf8))
				if let msgType = json.object?["msgType"]?.string {
					do {
						switch (msgType) {
						case "newBlock":
							//TODO
							try test()
						case "getBlocks":
							//TODO
							try test()
						case "getLatestBlock":
							//TODO
							try test()
						case "getDifficulty":
						//TODO
							try test()
						default:
							//TODO
							try test()
						}
					} catch {
						print("fuck")
					}
				}
			}
			
			func test() throws {
				//TODO
			}
		}
    }
}
