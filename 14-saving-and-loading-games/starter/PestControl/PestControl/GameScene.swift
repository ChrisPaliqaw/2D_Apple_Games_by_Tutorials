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
  
  var bugsNode = SKNode()
  var obstaclesTileMap: SKTileMapNode?
  var bugsprayTileMap: SKTileMapNode?
  
  var firebugCount: Int = 0
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    background =
      childNode(withName: "background") as! SKTileMapNode
    obstaclesTileMap = childNode(withName: "obstacles")
      as? SKTileMapNode
  }
  
  // MARK:- Setup scene
  override func didMove(to view: SKView) {
    addChild(player)
    
    setupCamera()
    setupWorldPhysics()
    
    createBugs()
    setupObstaclePhysics()
    
    if firebugCount > 0 {
      createBugspray(quantity: firebugCount + 10)
    }
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
    
    background.physicsBody?.categoryBitMask = PhysicsCategory.Edge
    physicsWorld.contactDelegate = self
  }
  
  func createBugs() {
    guard let bugsMap = childNode(withName: "bugs")
      as? SKTileMapNode else { return }
    // 1
    for row in 0..<bugsMap.numberOfRows {
      for column in 0..<bugsMap.numberOfColumns {
        // 2
        guard let tile = tile(in: bugsMap,
                              at: (column, row))
          else { continue }
        // 3
        let bug: Bug
        if tile.userData?.object(forKey: "firebug") != nil {
          bug = Firebug()
          firebugCount += 1
        } else {
          bug = Bug()
        }
        bug.position = bugsMap.centerOfTile(atColumn: column,
                                            row: row)
        bugsNode.addChild(bug)
        bug.move()
      }
    }
    // 4
    bugsNode.name = "Bugs"
    addChild(bugsNode)
    // 5
    bugsMap.removeFromParent()
  }
  
  func setupObstaclePhysics() {
    guard let obstaclesTileMap = obstaclesTileMap else { return }
    // 1
    for row in 0..<obstaclesTileMap.numberOfRows {
      for column in 0..<obstaclesTileMap.numberOfColumns {
        // 2
        guard let tile = tile(in: obstaclesTileMap,
                              at: (column, row))
          else { continue }
        guard tile.userData?.object(forKey: "obstacle") != nil
          else { continue }
        // 3
        let node = SKNode()
        node.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.friction = 0
        node.physicsBody?.categoryBitMask =
          PhysicsCategory.Breakable
        
        node.position = obstaclesTileMap.centerOfTile(
          atColumn: column, row: row)
        obstaclesTileMap.addChild(node)
      }
    }
  }
  
  func createBugspray(quantity: Int) {
    // 1
    let tile = SKTileDefinition(texture:
      SKTexture(pixelImageNamed: "bugspray"))
    // 2
    let tilerule = SKTileGroupRule(adjacency:
      SKTileAdjacencyMask.adjacencyAll, tileDefinitions: [tile])
    // 3
    let tilegroup = SKTileGroup(rules: [tilerule])
    // 4
    let tileSet = SKTileSet(tileGroups: [tilegroup])
    // 5
    let columns = background.numberOfColumns
    let rows = background.numberOfRows
    bugsprayTileMap = SKTileMapNode(tileSet: tileSet,
                                    columns: columns,
                                    rows: rows,
                                    tileSize: tile.size)
    // 6
    for _ in 1...quantity {
      let column = Int.random(min: 0, max: columns-1)
      let row = Int.random(min: 0, max: rows-1)
      bugsprayTileMap?.setTileGroup(tilegroup,
                                    forColumn: column, row: row)
    }
    // 7
    bugsprayTileMap?.name = "Bugspray"
    addChild(bugsprayTileMap!)
  }
  
  // MARK:- Process Game
  override func touchesBegan(_ touches: Set<UITouch>,
                             with event: UIEvent?) {
    guard let touch = touches.first else { return }
    player.move(target: touch.location(in: self))
  }
  
  override func update(_ currentTime: TimeInterval) {
    if !player.hasBugspray {
      updateBugspray()
    }
    advanceBreakableTile(locatedAt: player.position)
  }
  
  func updateBugspray() {
    guard let bugsprayTileMap = bugsprayTileMap else { return }
    let (column, row) = tileCoordinates(in: bugsprayTileMap,
                                        at: player.position)
    if tile(in: bugsprayTileMap, at: (column, row)) != nil {
      bugsprayTileMap.setTileGroup(nil, forColumn: column,
                                   row: row)
      player.hasBugspray = true
    }
  }
  
  func advanceBreakableTile(locatedAt nodePosition: CGPoint) {
    guard let obstaclesTileMap = obstaclesTileMap else { return }
    // 1
    let (column, row) = tileCoordinates(in: obstaclesTileMap,
                                        at: nodePosition)
    // 2
    let obstacle = tile(in: obstaclesTileMap,
                        at: (column, row))
    // 3
    guard let nextTileGroupName =
      obstacle?.userData?.object(forKey: "breakable") as? String
      else { return }
    // 4
    if let nextTileGroup =
      tileGroupForName(tileSet: obstaclesTileMap.tileSet,
                       name: nextTileGroupName) {
      obstaclesTileMap.setTileGroup(nextTileGroup,
                                    forColumn: column, row: row)
    }
  }
  
  // MARK:- Helper methods
  func tile(in tileMap: SKTileMapNode,
            at coordinates: TileCoordinates)
    -> SKTileDefinition? {
      return tileMap.tileDefinition(atColumn: coordinates.column,
                                    row: coordinates.row)
  }
  
  func tileCoordinates(in tileMap: SKTileMapNode,
                       at position: CGPoint) -> TileCoordinates {
    let column = tileMap.tileColumnIndex(fromPosition: position)
    let row = tileMap.tileRowIndex(fromPosition: position)
    return (column, row)
  }
  
  func tileGroupForName(tileSet: SKTileSet, name: String)
    -> SKTileGroup? {
      let tileGroup = tileSet.tileGroups
        .filter { $0.name == name }.first
      return tileGroup
  }
}

// MARK:- SKPhysicsContactDelegate
extension GameScene : SKPhysicsContactDelegate {
  
  func didBegin(_ contact: SKPhysicsContact) {
    let other = contact.bodyA.categoryBitMask
      == PhysicsCategory.Player ?
        contact.bodyB : contact.bodyA
    
    switch other.categoryBitMask {
    case PhysicsCategory.Bug:
      if let bug = other.node as? Bug {
        remove(bug: bug)
      }
    case PhysicsCategory.Firebug:
      if player.hasBugspray {
        if let firebug = other.node as? Firebug {
          remove(bug: firebug)
          player.hasBugspray = false
        }
      }
    case PhysicsCategory.Breakable:
      if let obstacleNode = other.node {
        // 1
        advanceBreakableTile(locatedAt: obstacleNode.position)
        // 2
        obstacleNode.removeFromParent()
      }
    default:
      break
    }
    
    if let physicsBody = player.physicsBody {
      if physicsBody.velocity.length() > 0 {
        player.checkDirection()
      }
    }
  }
  
  func remove(bug: Bug) {
    bug.removeFromParent()
    background.addChild(bug)
    bug.die()
  }
  
}
