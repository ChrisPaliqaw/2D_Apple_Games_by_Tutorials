import SpriteKit
class GameScene: SKScene {
    // MARK: - Properties
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    
    let playableRect: CGRect
    
    let zombieInitialPosition = CGPoint(x: 400, y: 400)
    
    var lastTouchLocation:CGPoint
    
    var timeLastTouched = Date()
    let minTimeBetweenTouches = TimeInterval(0.5)
    
    // MARK: - Lifecycle
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 2.17 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0,
                              y: playableMargin,
                              width: size.width,
                              height: playableHeight) // 4
        lastTouchLocation = zombieInitialPosition
        super.init(size: size) // 5
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
        
        let amountToMove = velocity * CGFloat(dt)
        if (zombie.position - lastTouchLocation).length() < amountToMove.length() {
            zombie.position = lastTouchLocation
            velocity = CGPoint.zero
        } else if velocity != CGPoint.zero {
            move(sprite: zombie, velocity: velocity)
            rotate(sprite: zombie, direction: velocity)
        }
        boundsCheckZombie()
    }
    
    // MARK: - Helpers
    
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
        let currentTime = Date()
        let newDelta =
            currentTime.timeIntervalSince(self.timeLastTouched)
        timeLastTouched = currentTime
        if newDelta.isLess(than: minTimeBetweenTouches) {
            return
        }
        lastTouchLocation = touchLocation
        moveZombieToward(location: touchLocation)
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zRotation = direction.angle
    }
    
    //  @objc func handleTap(recognizer: UIGestureRecognizer) {
    //    let viewLocation = recognizer.location(in: self.view)
    //    let touchLocation = convertPoint(fromView: viewLocation)
    //    sceneTouched(touchLocation: touchLocation)
    //  }
    
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
