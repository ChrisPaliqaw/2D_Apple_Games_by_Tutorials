import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    override init(size: CGSize) {
        super.init(size: size)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu")
        background.position =
            CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(background)
        
        let myScene = GameScene(size: self.size)
        myScene.scaleMode = self.scaleMode
        let reveal = SKTransition.doorway(withDuration: 1.5)
        self.view?.presentScene(myScene, transition: reveal)
    }
}
