import SpriteKit
class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")
        
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        let background = SKSpriteNode(imageNamed: "background1")
        
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
        zombie.position = CGPoint(x: 400, y: 400)
        addChild(zombie)
        zombie.setScale(2.0)
        
        let mySize = background.size
        print("Size: \(mySize)")
    }
}
