import SpriteKit

class BedNode: SKSpriteNode, EventListenerNode {
    func didMoveToScene() {
        print("bed added to scene")
    }
}
