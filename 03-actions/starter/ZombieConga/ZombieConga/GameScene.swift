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

  let zombie = SKSpriteNode(imageNamed: "zombie1")
  var lastUpdateTime: TimeInterval = 0
  var dt: TimeInterval = 0
  let zombieMovePointsPerSec: CGFloat = 480.0
  var velocity = CGPoint.zero
  let playableRect: CGRect
  var lastTouchLocation: CGPoint?
  let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
  
  override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0 // 1
    let playableHeight = size.width / maxAspectRatio // 2
    let playableMargin = (size.height-playableHeight)/2.0 // 3
    playableRect = CGRect(x: 0, y: playableMargin,
                          width: size.width,
                          height: playableHeight) // 4
    super.init(size: size) // 5
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented") // 6
  }

  func debugDrawPlayableArea() {
    let shape = SKShapeNode(rect: playableRect)
    shape.strokeColor = SKColor.red
    shape.lineWidth = 4.0
    addChild(shape)
  }

  override func didMove(to view: SKView) {
    backgroundColor = SKColor.black
    let background = SKSpriteNode(imageNamed: "background1")
    background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
    background.position = CGPoint(x: size.width/2, y: size.height/2)
    // background.zRotation = CGFloat.pi / 8
    background.zPosition = -1
    addChild(background)

    let mySize = background.size
    print("Size: \(mySize)")

    zombie.position = CGPoint(x: 400, y: 400)
    // zombie.setScale(2) // SKNode method
    addChild(zombie)

//    // Gesture recognizer example
//    // Uncomment this and the handleTap method, and comment the touchesBegan/Moved methods to test
//    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//    view.addGestureRecognizer(tapRecognizer)

    debugDrawPlayableArea()
  }

  override func update(_ currentTime: TimeInterval) {
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime
    print("\(dt*1000) milliseconds since last update")

    if let lastTouchLocation = lastTouchLocation {
      let diff = lastTouchLocation - zombie.position
      if diff.length() <= zombieMovePointsPerSec * CGFloat(dt) {
        zombie.position = lastTouchLocation
        velocity = CGPoint.zero
      } else {
        move(sprite: zombie, velocity: velocity)
        rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
      }
    }

    boundsCheckZombie()
  }

  func move(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
    print("Amount to move: \(amountToMove)")
    sprite.position += amountToMove
  }

  func moveZombieToward(location: CGPoint) {
    let offset = location - zombie.position
    let direction = offset.normalized()
    velocity = direction * zombieMovePointsPerSec
  }

  func sceneTouched(touchLocation:CGPoint) {
    lastTouchLocation = touchLocation
    moveZombieToward(location: touchLocation)
  }

  override func touchesBegan(_ touches: Set<UITouch>,
      with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.location(in: self)
    sceneTouched(touchLocation: touchLocation)
  }

  override func touchesMoved(_ touches: Set<UITouch>,
      with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.location(in: self)
    sceneTouched(touchLocation: touchLocation)
  }

//  @objc func handleTap(recognizer: UIGestureRecognizer) {
//    let viewLocation = recognizer.location(in: self.view)
//    let touchLocation = convertPoint(fromView: viewLocation)
//    sceneTouched(touchLocation: touchLocation)
//  }

  func boundsCheckZombie() {
    let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
    let topRight = CGPoint(x: size.width, y: playableRect.maxY)

    if zombie.position.x <= bottomLeft.x {
      zombie.position.x = bottomLeft.x
      velocity.x = -velocity.x
    }
    if zombie.position.x >= topRight.x {
      zombie.position.x = topRight.x
      velocity.x = -velocity.x
    }
    if zombie.position.y <= bottomLeft.y {
      zombie.position.y = bottomLeft.y
      velocity.y = -velocity.y
    }
    if zombie.position.y >= topRight.y {
      zombie.position.y = topRight.y
      velocity.y = -velocity.y
    }
  }

  func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
    let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
    let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
    sprite.zRotation += shortest.sign() * amountToRotate
  }

}
