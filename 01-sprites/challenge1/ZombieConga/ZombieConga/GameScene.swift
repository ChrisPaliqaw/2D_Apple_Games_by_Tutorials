import SpriteKit
class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        let background = SKSpriteNode(imageNamed: "background1")
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        //background.zRotation = CGFloat.pi / 8
        background.zPosition = -1
        addChild(background)
        
        let mySize = background.size
        print("Size: \(mySize)")
    }
}
