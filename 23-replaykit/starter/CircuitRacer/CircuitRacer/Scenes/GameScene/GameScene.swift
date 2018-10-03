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
import GameplayKit
import GameKit

protocol GameSceneProtocol: class {
  func didSelectCancelButton(gameScene: GameScene)
  func didShowOverlay(gameScene: GameScene)
  func didDismissOverlay(gameScene: GameScene)
}

class GameScene: SKScene {
  
  // Achievements Challenge 1
  static var numberOfPlays = 0
  
  weak var gameSceneDelegate: GameSceneProtocol?
  
  var carType: CarType!
  var levelType: LevelType!
  
  var lastUpdateTimeInterval: TimeInterval = 0
  
  var box1: SKSpriteNode!, box2: SKSpriteNode!
  var laps: SKLabelNode!, time: SKLabelNode!
  
  var maxSpeed = 0
  
  var lapSoundAction: SKAction!, boxSoundAction: SKAction!
 
  private var buttons: [ButtonNode] = []
  var noOfCollisions = 0
  
  static let CarCategoryMask: UInt32 = 1
  static let BoxCategoryMask: UInt32 = 2
  
  let leaderboardIDMap =
    ["\(CarType.yellow.rawValue)_\(LevelType.easy.rawValue)": "com.razeware.CircuitRacer.yellowcar_easylevel_fastest_time",
     "\(CarType.yellow.rawValue)_\(LevelType.medium.rawValue)": "com.razeware.CircuitRacer.yellowcar_mediumlevel_fastest_time",
     "\(CarType.yellow.rawValue)_\(LevelType.hard.rawValue)": "com.razeware.CircuitRacer.yellowcar_hardlevel_fastest_time",
     "\(CarType.blue.rawValue)_\(LevelType.easy.rawValue)": "com.razeware.CircuitRacer.bluecar_easylevel_fastest_time",
     "\(CarType.blue.rawValue)_\(LevelType.medium.rawValue)": "com.razeware.CircuitRacer.bluecar_mediumlevel_fastest_time",
     "\(CarType.blue.rawValue)_\(LevelType.hard.rawValue)": "com.razeware.CircuitRacer.bluecar_hardlevel_fastest_time",
     "\(CarType.red.rawValue)_\(LevelType.easy.rawValue)": "com.razeware.CircuitRacer.redcar_easylevel_fastest_time",
     "\(CarType.red.rawValue)_\(LevelType.medium.rawValue)": "com.razeware.CircuitRacer.redcar_mediumlevel_fastest_time",
     "\(CarType.red.rawValue)_\(LevelType.hard.rawValue)": "com.razeware.CircuitRacer.redcar_hardlevel_fastest_time"]
  
  var overlay: SceneOverlay? {
    didSet {
      
      buttons = []
      oldValue?.backgroundNode.removeFromParent()
      
      if let overlay = overlay, let camera = camera {
        overlay.backgroundNode.position.y = -overlapAmount()/2
        camera.addChild(overlay.backgroundNode)
        
        buttons = findAllButtonsInScene()

        gameSceneDelegate?.didShowOverlay(gameScene: self)
      } else {
        gameSceneDelegate?.didDismissOverlay(gameScene: self)
      }
    }
  }
  
  lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
      GameActiveState(gameScene: self),
      GamePauseState(gameScene: self),
      GameFailureState(gameScene: self),
      GameSuccessState(gameScene: self)
    ])
  
  override func didMove(to view: SKView) {
    
    setupPhysicsBodies()
    
    ButtonNode.parseButtonInNode(containerNode: self)
    
    let pauseButton = childNode(withName: "pause") as! SKSpriteNode
    pauseButton.anchorPoint = .zero
    pauseButton.position = CGPoint(x: size.width - pauseButton.size.width, y: size.height - pauseButton.size.height - overlapAmount()/2)
    
    boxSoundAction = SKAction.playSoundFileNamed("box.wav",
      waitForCompletion: false)
    lapSoundAction = SKAction.playSoundFileNamed("lap.wav",
      waitForCompletion: false)
    
    box1 = childNode(withName: "box_1") as! SKSpriteNode
    box2 = childNode(withName: "box_2") as! SKSpriteNode
    
    laps = self.childNode(withName: "laps_label") as! SKLabelNode
    time = self.childNode(withName: "time_left_label") as! SKLabelNode
    
    childNode(withName: "car")?.physicsBody?.contactTestBitMask =
      GameScene.BoxCategoryMask
    
    let camera = SKCameraNode()
    scene?.camera = camera
    scene?.addChild(camera)
    setCameraPosition(position: CGPoint(x: size.width/2, y: size.height/2))
    
    stateMachine.enter(GameActiveState.self)
    physicsWorld.contactDelegate = self
  }
 
  override func update(_ currentTime: CFTimeInterval) {
    
    let deltaTime = currentTime - lastUpdateTimeInterval
    stateMachine.update(deltaTime: deltaTime)
  }
  
  func reportAllAchievementsForGameState(hasWon: Bool) {
    var achievements: [GKAchievement] = []
    
    achievements.append(AchievementsHelper.collisionAchievement(
      noOfCollisions: noOfCollisions))
    
    if hasWon {
      achievements.append(AchievementsHelper.achievementForLevel(
        levelType: levelType))
    }
    
    // Achievements Challenge 1
    GameScene.numberOfPlays += 1
    achievements.append(AchievementsHelper.racingAddictAchievement(noOfPlays: GameScene.numberOfPlays))
    
    GameKitHelper.sharedInstance.reportAchievements(achievements: achievements)
  }
  
  func reportScoreToGameCenter(score: Int64) {
    GameKitHelper.sharedInstance.reportScore(score: score, forLeaderboardID:
      leaderboardIDMap["\(carType.rawValue)_\(levelType.rawValue)"]!)
  }
  
  // MARK: Private methods
  
  private func setupPhysicsBodies() {
    let innerBoundary = SKNode()
    
    let track = childNode(withName: "track")!
    innerBoundary.position = CGPoint(x: track.position.x + track.frame.size.width/2, y: track.position.y + track.frame.size.height/2)

    addChild(innerBoundary)

    innerBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 720, height: 480))
    innerBoundary.physicsBody!.isDynamic = false

    let trackFrame = childNode(withName: "track")!.frame.insetBy(dx: 200, dy: 0)

    let maxAspectRatio: CGFloat = 3.0/2.0 // iPhone 4
    let maxAspectRatioHeight = trackFrame.size.width / maxAspectRatio
    let playableMarginY: CGFloat = (trackFrame.size.height - maxAspectRatioHeight)/2
    let playableMarginX: CGFloat = (frame.size.width - trackFrame.size.width)/2

    let playableRect = CGRect(x: playableMarginX,
                              y: playableMarginY,
                              width: trackFrame.size.width,
                              height: trackFrame.size.height - playableMarginY*2)
    
    physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
  }
  
  private func overlapAmount() -> CGFloat {
    guard let view = self.view else {
      return 0
    }
    let scale = view.bounds.size.width / self.size.width
    let scaledHeight = self.size.height * scale
    let scaledOverlap = scaledHeight - view.bounds.size.height
    return scaledOverlap / scale
  }
  
  private func setCameraPosition(position: CGPoint) {
    scene?.camera?.position = CGPoint(x: position.x, y: position.y)
  }
}

extension GameScene: InputControlProtocol {
  func directionChangedWithMagnitude(position: CGPoint) {
    if isPaused {
      return
    }
    
    if let car = self.childNode(withName: "car") as? SKSpriteNode, let carPhysicsBody = car.physicsBody {
      
      carPhysicsBody.velocity = CGVector(
        dx: position.x * CGFloat(maxSpeed),
        dy: position.y * CGFloat(maxSpeed))
      
      if position != CGPoint.zero {
        car.zRotation = CGPoint(x: position.x, y: position.y).angle
      }
    }
  }
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    if contact.bodyA.categoryBitMask != UInt32.max
      && contact.bodyB.categoryBitMask != UInt32.max
      && (contact.bodyA.categoryBitMask + contact.bodyB.categoryBitMask
        == GameScene.CarCategoryMask + GameScene.BoxCategoryMask) {
      
      noOfCollisions += 1
      run(boxSoundAction)
    }
  }
}

