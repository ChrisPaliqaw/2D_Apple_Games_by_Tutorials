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
  let zombieAnimation: SKAction
  var invincible = false
  let catMovePointsPerSec:CGFloat = 480.0
  var lives = 5
  var gameOver = false

  let catCollisionSound: SKAction = SKAction.playSoundFileNamed(
    "hitCat.wav", waitForCompletion: false)
  let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
    "hitCatLady.wav", waitForCompletion: false)

  override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height-playableHeight)/2.0
    playableRect = CGRect(x: 0, y: playableMargin,
                          width: size.width,
                          height: playableHeight)
    // 1
    var textures:[SKTexture] = []
    // 2
    for i in 1...4 {
      textures.append(SKTexture(imageNamed: "zombie\(i)"))
    }
    // 3
    textures.append(textures[2])
    textures.append(textures[1])

    // 4
    zombieAnimation = SKAction.animate(with: textures,
      timePerFrame: 0.1)

    super.init(size: size)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
    background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    background.position = CGPoint(x: size.width/2, y: size.height/2)
    background.zPosition = -1
    addChild(background)

    zombie.position = CGPoint(x: 400, y: 400)
    zombie.zPosition = 100
    addChild(zombie)
    // zombie.run(SKAction.repeatForever(zombieAnimation))

    run(SKAction.repeatForever(
      SKAction.sequence([SKAction.run() { [weak self] in
                          self?.spawnEnemy()
                        },
                        SKAction.wait(forDuration: 2.0)])))

    run(SKAction.repeatForever(
      SKAction.sequence([SKAction.run() { [weak self] in
                          self?.spawnCat()
                        },
                        SKAction.wait(forDuration: 1.0)])))

    // debugDrawPlayableArea()

    playBackgroundMusic(filename: "backgroundMusic.mp3")
  }

  override func update(_ currentTime: TimeInterval) {
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime

    if let lastTouchLocation = lastTouchLocation {
      let diff = lastTouchLocation - zombie.position
      if diff.length() <= zombieMovePointsPerSec * CGFloat(dt) {
        zombie.position = lastTouchLocation
        velocity = CGPoint.zero
        stopZombieAnimation()
      } else {
        move(sprite: zombie, velocity: velocity)
        rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
      }
    }

    boundsCheckZombie()
    // checkCollisions()
    moveTrain()

    if lives <= 0 && !gameOver {
      gameOver = true
      print("You lose!")
      backgroundMusicPlayer.stop()

      // 1
      let gameOverScene = GameOverScene(size: size, won: false)
      gameOverScene.scaleMode = scaleMode
      // 2
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      // 3
      view?.presentScene(gameOverScene, transition: reveal)

    }
  }

  override func didEvaluateActions() {
    checkCollisions()
  }

  func move(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
    sprite.position += amountToMove
  }

  func moveZombieToward(location: CGPoint) {
    startZombieAnimation()
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

  func spawnEnemy() {
    let enemy = SKSpriteNode(imageNamed: "enemy")
    enemy.name = "enemy"
    enemy.position = CGPoint(
      x: size.width + enemy.size.width/2,
      y: CGFloat.random(
        min: playableRect.minY + enemy.size.height/2,
        max: playableRect.maxY - enemy.size.height/2))
    addChild(enemy)

    let actionMove =
      SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
    let actionRemove = SKAction.removeFromParent()
    enemy.run(SKAction.sequence([actionMove, actionRemove]))
  }

  func startZombieAnimation() {
    if zombie.action(forKey: "animation") == nil {
      zombie.run(
        SKAction.repeatForever(zombieAnimation),
        withKey: "animation")
    }
  }

  func stopZombieAnimation() {
    zombie.removeAction(forKey: "animation")
  }

  func spawnCat() {
    // 1
    let cat = SKSpriteNode(imageNamed: "cat")
    cat.name = "cat"
    cat.position = CGPoint(
      x: CGFloat.random(min: playableRect.minX,
                        max: playableRect.maxX),
      y: CGFloat.random(min: playableRect.minY,
                        max: playableRect.maxY))
    cat.setScale(0)
    addChild(cat)
    // 2
    let appear = SKAction.scale(to: 1.0, duration: 0.5)
    cat.zRotation = -π / 16.0
    let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
    let rightWiggle = leftWiggle.reversed()
    let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
    let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
    let scaleDown = scaleUp.reversed()
    let fullScale = SKAction.sequence(
      [scaleUp, scaleDown, scaleUp, scaleDown])
    let group = SKAction.group([fullScale, fullWiggle])
    let groupWait = SKAction.repeat(group, count: 10)
    let disappear = SKAction.scale(to: 0, duration: 0.5)
    let removeFromParent = SKAction.removeFromParent()
    let actions = [appear, groupWait, disappear, removeFromParent]
    cat.run(SKAction.sequence(actions))
  }

  func zombieHit(cat: SKSpriteNode) {
    cat.name = "train"
    cat.removeAllActions()
    cat.setScale(1.0)
    cat.zRotation = 0

    let turnGreen = SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2)
    cat.run(turnGreen)

    run(catCollisionSound)
  }

  func zombieHit(enemy: SKSpriteNode) {
    invincible = true
    let blinkTimes = 10.0
    let duration = 3.0
    let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
      let slice = duration / blinkTimes
      let remainder = Double(elapsedTime).truncatingRemainder(
        dividingBy: slice)
      node.isHidden = remainder > slice / 2
    }
    let setHidden = SKAction.run() { [weak self] in
      self?.zombie.isHidden = false
      self?.invincible = false
    }
    zombie.run(SKAction.sequence([blinkAction, setHidden]))

    run(enemyCollisionSound)

    loseCats()
    lives -= 1
  }

  func checkCollisions() {
    var hitCats: [SKSpriteNode] = []
    enumerateChildNodes(withName: "cat") { node, _ in
      let cat = node as! SKSpriteNode
      if cat.frame.intersects(self.zombie.frame) {
        hitCats.append(cat)
      }
    }
    for cat in hitCats {
      zombieHit(cat: cat)
    }

    if invincible {
      return
    }

    var hitEnemies: [SKSpriteNode] = []
    enumerateChildNodes(withName: "enemy") { node, _ in
      let enemy = node as! SKSpriteNode
      if node.frame.insetBy(dx: 20, dy: 20).intersects(
        self.zombie.frame) {
        hitEnemies.append(enemy)
      }
    }
    for enemy in hitEnemies {
      zombieHit(enemy: enemy)
    }
  }

  func moveTrain() {

    var trainCount = 0
    var targetPosition = zombie.position

    enumerateChildNodes(withName: "train") { node, stop in
      trainCount += 1
      if !node.hasActions() {
        let actionDuration = 0.3
        let offset = targetPosition - node.position
        let direction = offset.normalized()
        let amountToMovePerSec = direction * self.catMovePointsPerSec
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
        let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
        node.run(moveAction)
      }
      targetPosition = node.position
    }

    if trainCount >= 15 && !gameOver {
      gameOver = true
      print("You win!")
      backgroundMusicPlayer.stop()

      // 1
      let gameOverScene = GameOverScene(size: size, won: true)
      gameOverScene.scaleMode = scaleMode
      // 2
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      // 3
      view?.presentScene(gameOverScene, transition: reveal)

    }
  }

  func loseCats() {
    // 1
    var loseCount = 0
    enumerateChildNodes(withName: "train") { node, stop in
      // 2
      var randomSpot = node.position
      randomSpot.x += CGFloat.random(min: -100, max: 100)
      randomSpot.y += CGFloat.random(min: -100, max: 100)
      // 3
      node.name = ""
      node.run(
        SKAction.sequence([
          SKAction.group([
            SKAction.rotate(byAngle: π*4, duration: 1.0),
            SKAction.move(to: randomSpot, duration: 1.0),
            SKAction.scale(to: 0, duration: 1.0)
            ]),
          SKAction.removeFromParent()
        ]))
      // 4
      loseCount += 1
      if loseCount >= 2 {
        stop[0] = true
      }
    }
  }

}
