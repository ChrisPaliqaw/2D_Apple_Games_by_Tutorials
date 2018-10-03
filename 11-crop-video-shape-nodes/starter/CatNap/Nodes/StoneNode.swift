/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit

class StoneNode: SKSpriteNode, EventListenerNode, InteractiveNode {
  func didMoveToScene() {
    guard let scene = scene else {
      return
    }
    
    if parent == scene {
      scene.addChild(StoneNode.makeCompoundNode(in: scene))
    }
  }
  
  func interact() {
    isUserInteractionEnabled = false
    
    run(SKAction.sequence([
      SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false),
      SKAction.removeFromParent()
      ]))
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    interact()
  }
  
  static func makeCompoundNode(in scene: SKScene) -> SKNode {
    let compound = StoneNode()
    
    for stone in scene.children
      .filter({ node in node is StoneNode}) {
        stone.removeFromParent()
        compound.addChild(stone)
    }
    
    let bodies = compound.children.map { node in
      SKPhysicsBody(rectangleOf: node.frame.size, center: node.position)
    }
    
    compound.physicsBody = SKPhysicsBody(bodies: bodies)
    compound.physicsBody!.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Cat | PhysicsCategory.Block
    compound.physicsBody!.categoryBitMask = PhysicsCategory.Block
    compound.isUserInteractionEnabled = true
    compound.zPosition = 1
    
    return compound
  }
}
