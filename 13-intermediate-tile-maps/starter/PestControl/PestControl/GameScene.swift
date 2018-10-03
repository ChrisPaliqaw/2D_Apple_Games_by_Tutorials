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

class GameScene: SKScene {
  
  var background: SKTileMapNode!
  var player = Player()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    background =
      childNode(withName: "background") as! SKTileMapNode
  }
  
  override func didMove(to view: SKView) {
    addChild(player)
    
    let bug = Bug()
    bug.position = CGPoint(x: 60, y: 0)
    addChild(bug)
    
    setupCamera()
    setupWorldPhysics()
  }
  
  func setupCamera() {
    guard let camera = camera, let view = view else { return }
    
    let zeroDistance = SKRange(constantValue: 0)
    let playerConstraint = SKConstraint.distance(zeroDistance,
                                                 to: player)
    // 1
    let xInset = min(view.bounds.width/2 * camera.xScale,
                     background.frame.width/2)
    let yInset = min(view.bounds.height/2 * camera.yScale,
                     background.frame.height/2)
    
    // 2
    let constraintRect = background.frame.insetBy(dx: xInset,
                                                  dy: yInset)
    // 3
    let xRange = SKRange(lowerLimit: constraintRect.minX,
                         upperLimit: constraintRect.maxX)
    let yRange = SKRange(lowerLimit: constraintRect.minY,
                         upperLimit: constraintRect.maxY)
    
    let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
    edgeConstraint.referenceNode = background
    // 4
    camera.constraints = [playerConstraint, edgeConstraint]
  }
  
  func setupWorldPhysics() {
    background.physicsBody =
      SKPhysicsBody(edgeLoopFrom: background.frame)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
                             with event: UIEvent?) {
    guard let touch = touches.first else { return }
    player.move(target: touch.location(in: self))
  }
}
