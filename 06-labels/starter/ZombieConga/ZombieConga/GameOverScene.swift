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

import Foundation
import SpriteKit

class GameOverScene: SKScene {
  let won:Bool

  init(size: CGSize, won: Bool) {
    self.won = won
    super.init(size: size)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMove(to view: SKView) {
    var background: SKSpriteNode
    if (won) {
      background = SKSpriteNode(imageNamed: "YouWin")
      run(SKAction.playSoundFileNamed("win.wav",
          waitForCompletion: false))
    } else {
      background = SKSpriteNode(imageNamed: "YouLose")
      run(SKAction.playSoundFileNamed("lose.wav",
          waitForCompletion: false))
    }

    background.position =
      CGPoint(x: size.width/2, y: size.height/2)
    self.addChild(background)

    // More here...
    let wait = SKAction.wait(forDuration: 3.0)
    let block = SKAction.run {
      let myScene = GameScene(size: self.size)
      myScene.scaleMode = self.scaleMode
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      self.view?.presentScene(myScene, transition: reveal)
    }
    self.run(SKAction.sequence([wait, block]))
  }

}
