import SpriteKit

protocol EventListenerNode {
    func didMoveToScene()
}

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Cat: UInt32 = 0b1 // 1
    static let Block: UInt32 = 0b10 // 2
    static let Bed: UInt32 = 0b100 // 4
    static let Edge: UInt32 = 0b1000 // 8
    static let Label: UInt32 = 0b10000 // 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var bedNode: BedNode!
    var catNode: CatNode!
    
    var playable = true
    
    override func didMove(to view: SKView) {
        // Calculate playable margin
        let maxAspectRatio: CGFloat = 2.16
        let maxAspectRatioHeight = size.width / maxAspectRatio
        let playableMargin: CGFloat = (size.height
            - maxAspectRatioHeight)/2
        let playableRect = CGRect(x: 0, y: playableMargin,
                                  width: size.width, height: size.height-playableMargin*2)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
        physicsWorld.contactDelegate = self
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        isPaused = true
        isPaused = false
        
        enumerateChildNodes(withName: "//*", using: { node, _ in
            if let eventListenerNode = node as? EventListenerNode {
                eventListenerNode.didMoveToScene()
            }
        })
        
        bedNode = (childNode(withName: "bed") as! BedNode)
        catNode = (childNode(withName: "//cat_body") as! CatNode)
        
        SKTAudio.sharedInstance()
            .playBackgroundMusic("backgroundMusic.mp3")
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask
            | contact.bodyB.categoryBitMask
        
        // challenge 1
        if collision == PhysicsCategory.Label | PhysicsCategory.Edge {
            let labelNode = contact.bodyA.categoryBitMask == PhysicsCategory.Label ?
                contact.bodyA.node :
                contact.bodyB.node
            
            if let message = labelNode as? MessageNode {
                message.didBounce()
            }
        }
        
        if !playable {
            return
        }
        
        if collision == PhysicsCategory.Cat | PhysicsCategory.Bed {
            print("SUCCESS")
            win()
        } else if collision == PhysicsCategory.Cat
            | PhysicsCategory.Edge {
            print("FAIL")
            lose()
        }
    }
    
    func inGameMessage(text: String) {
        let message = MessageNode(message: text)
        message.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(message)
    }
    
    func newGame() {
        let scene = GameScene(fileNamed:"GameScene")
        scene!.scaleMode = scaleMode
        view!.presentScene(scene)
    }
    
    func lose() {
        playable = false
        //1
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        SKTAudio.sharedInstance().playSoundEffect("lose.mp3")
        //2
        inGameMessage(text: "Try again...")
        //3
        run(SKAction.afterDelay(5, runBlock: newGame))
        catNode.wakeUp()
    }
    
    func win() {
        playable = false
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        SKTAudio.sharedInstance().playSoundEffect("win.mp3")
        inGameMessage(text: "Nice job!")
        run(SKAction.afterDelay(3, runBlock: newGame))
        catNode.curlAt(scenePoint: bedNode.position)
    }
}

protocol InteractiveNode {
    func interact()
}
