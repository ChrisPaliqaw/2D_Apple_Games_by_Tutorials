import SpriteKit
class GameScene: SKScene {
    // MARK: - Properties
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    
    let playableRect: CGRect
    
    let zombieInitialPosition = CGPoint(x: 400, y: 400)
    let zombieZPosition:CGFloat = 100.0
    
    var lastTouchLocation:CGPoint
    
    let zombieAnimation: SKAction
    
    let catName = "cat"
    let zombieCatName = "train"
    let enemyName = "enemy"
    
    let animationKey = "animation"
    
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCatLady.wav", waitForCompletion: false)
    
    var isZombieInvincible = false
    
    let zombieCatMovePointsPerSecond:CGFloat = 480.0
    
    var lives = 5
    var gameOver = false
    
    // MARK: - Lifecycle
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 2.16 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0,
                              y: playableMargin,
                              width: size.width,
                              height: playableHeight) // 4
        lastTouchLocation = zombieInitialPosition
        
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
        fatalError("init(coder:) has not been implemented") // 6
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        let background = SKSpriteNode(imageNamed: "background1")
        
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
        zombie.position = zombieInitialPosition
        zombie.zPosition = zombieZPosition
        addChild(zombie)
        //zombie.run(SKAction.repeatForever(zombieAnimation))
        
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
        
        playBackgroundMusic(filename: "backgroundMusic.mp3")
        
        //    // Gesture recognizer example
        //    // Uncomment this and the handleTap method, and comment the touchesBegan/Moved methods to test
        //    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        //    view.addGestureRecognizer(tapRecognizer)
        
        // debugDrawPlayableArea()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        //print("\(dt*1000) milliseconds since last update")
        
        let amountToMove = velocity * CGFloat(dt)
        if (zombie.position - lastTouchLocation).length() < amountToMove.length() {
            zombie.position = lastTouchLocation
            velocity = CGPoint.zero
            stopZombieAnimation()
        } else if velocity != CGPoint.zero {
            move(sprite: zombie, velocity: velocity)
            rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        }
        boundsCheckZombie()
        moveTrain()
        
        if lives <= 0 && !gameOver {
            gameOver(won: false)
        }
    }
    
    // MARK: - Helpers
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        //print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        startZombieAnimation()
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
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
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(location: touchLocation)
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: direction.angle)
        var amountToRotate = rotateRadiansPerSec * CGFloat(dt)
        if abs(shortest) < amountToRotate {
            amountToRotate = abs(shortest)
        }
        amountToRotate *= shortest.sign()
        sprite.zRotation += amountToRotate
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    //  @objc func handleTap(recognizer: UIGestureRecognizer) {
    //    let viewLocation = recognizer.location(in: self.view)
    //    let touchLocation = convertPoint(fromView: viewLocation)
    //    sceneTouched(touchLocation: touchLocation)
    //  }
    
    // MARK: - Spawn
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = enemyName
        enemy.position = CGPoint(
            x: size.width + enemy.size.width/2,
            y: CGFloat.random(
                in: (playableRect.minY + enemy.size.height/2)...(playableRect.maxY - enemy.size.height/2)))
        addChild(enemy)
        let actionMove =
            SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func spawnCat() {
        // 1
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = catName
        cat.position = CGPoint(
            x: CGFloat.random(in: playableRect.minX...playableRect.maxX),
            y: CGFloat.random(in: playableRect.minY...playableRect.maxY))
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
    
    // MARK: - Zombie animation
    
    func startZombieAnimation() {
        if zombie.action(forKey: animationKey) == nil {
            zombie.run(
                SKAction.repeatForever(zombieAnimation),
                withKey: animationKey)
        }
    }
    func stopZombieAnimation() {
        zombie.removeAction(forKey: animationKey)
    }
    
    // MARK: - Collisions
    
    func zombieHit(cat: SKSpriteNode) {
        //cat.removeFromParent()
        cat.name = zombieCatName
        cat.removeAllActions()
        cat.setScale(1)
        cat.zRotation = 0
        let turnGreenAction = SKAction.colorize(with: UIColor.green, colorBlendFactor: 1.0, duration: 0.2)
        cat.run(turnGreenAction)
        run(catCollisionSound)
    }
    
    func loseCats() {
        // 1
        var loseCount = 0
        enumerateChildNodes(withName: zombieCatName) { node, stop in
            // 2
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(in:-100...100)
            randomSpot.y += CGFloat.random(in:-100...100)
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
    
    func moveTrain() {
        var targetPosition = zombie.position
        var trainCount = 0
        
        enumerateChildNodes(withName: zombieCatName) { node, stop in
            trainCount += 1
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.zombieCatMovePointsPerSecond
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
        
        if trainCount >= 15 && !gameOver {
            gameOver(won: true)
        }
    }
    
    func zombieHit(enemy: SKSpriteNode) {
        //enemy.removeFromParent()
        run(enemyCollisionSound)
        loseCats()
        lives -= 1
        
        isZombieInvincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(
        withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(
                dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let endBlinkAction = SKAction.run() { [weak self] in
            self?.zombie.isHidden = false
            self?.isZombieInvincible = false
        }
        let zombieHitAction = SKAction.sequence([blinkAction, endBlinkAction])
        zombie.run(zombieHitAction)
    }
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: catName) { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHit(cat: cat)
        }
        var hitEnemies: [SKSpriteNode] = []
        if !isZombieInvincible {
            enumerateChildNodes(withName: enemyName) { node, _ in
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
    }
    
    func gameOver(won: Bool) {
        gameOver = true
        if won {
            print("You win!")
        } else {
            print("You lose!")
        }
        
        backgroundMusicPlayer.stop()
        
        let gameOverScene = GameOverScene(size: size, won: won)
        gameOverScene.scaleMode = scaleMode
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: reveal)
    }
    
    // MARK: - UIResponder
    
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

}
