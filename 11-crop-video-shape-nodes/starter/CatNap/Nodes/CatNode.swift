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

class CatNode: SKSpriteNode, EventListenerNode, InteractiveNode {
  static let kCatTappedNotification = "kCatTappedNotification"
  
  func didMoveToScene() {
    let catBodyTexture = SKTexture(imageNamed: "cat_body_outline")
    parent!.physicsBody = SKPhysicsBody(texture: catBodyTexture,
                                        size: catBodyTexture.size())
    parent!.physicsBody!.categoryBitMask = PhysicsCategory.Cat
    parent!.physicsBody!.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Edge | PhysicsCategory.Spring
    parent!.physicsBody!.contactTestBitMask = PhysicsCategory.Bed | PhysicsCategory.Edge
    
    isUserInteractionEnabled = true
  }
  
  func interact() {
    NotificationCenter.default.post(Notification(name:
      NSNotification.Name(CatNode.kCatTappedNotification), object: nil))
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    interact()
  }
  
  func wakeUp() {
    // 1
    for child in children {
      child.removeFromParent()
    }
    texture = nil
    color = SKColor.clear
    
    // 2
    let catAwake = SKSpriteNode(fileNamed: "CatWakeUp")!.childNode(withName: "cat_awake")!
    
    // 3
    catAwake.move(toParent: self)
    catAwake.position = CGPoint(x: -30, y: 100)
  }
  
  func curlAt(scenePoint: CGPoint) {
    parent!.physicsBody = nil
    for child in children {
      child.removeFromParent()
    }
    texture = nil
    color = SKColor.clear
    
    let catCurl = SKSpriteNode(fileNamed: "CatCurl")!.childNode(withName: "cat_curl")!
    catCurl.move(toParent: self)
    catCurl.position = CGPoint(x: -30, y: 100)
    
    var localPoint = parent!.convert(scenePoint, from: scene!)
    localPoint.y += frame.size.height/3
    
    run(SKAction.group([
      SKAction.move(to: localPoint, duration: 0.66),
      SKAction.rotate(toAngle: -parent!.zRotation, duration: 0.5)
      ]))
  }
}
