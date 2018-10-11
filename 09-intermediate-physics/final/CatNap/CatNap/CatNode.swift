import SpriteKit

class CatNode: SKSpriteNode, EventListenerNode {
    func didMoveToScene() {
        print("cat added to scene")
    }
}
