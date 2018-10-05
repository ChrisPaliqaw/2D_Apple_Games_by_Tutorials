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

  let playableRect: CGRect
  let cat:SKSpriteNode = SKSpriteNode(imageNamed: "cat")
  let dog:SKSpriteNode = SKSpriteNode(imageNamed: "dog")
  let turtle:SKSpriteNode = SKSpriteNode(imageNamed: "turtle")
  let label:SKLabelNode = SKLabelNode(fontNamed: "Verdana")
  
  override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0 // iPhone 5"
    let maxAspectRatioHeight = size.width / maxAspectRatio
    let playableMargin = (size.height-maxAspectRatioHeight)/2.0
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: size.height-playableMargin*2)

    super.init(size: size)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    
    backgroundColor = SKColor.white
    
    cat.position = CGPoint(x: size.width * 1/6, y: size.height / 2)
    addChild(cat)
    
    dog.position = CGPoint(x: size.width * 3/6, y: size.height / 2)
    addChild(dog)
    
    turtle.position = CGPoint(x: size.width * 5/6, y: size.height / 2)
    addChild(turtle)
    
    label.text = "Test"
    label.fontSize = 40
    label.fontColor = SKColor.black
    label.position = CGPoint(x: size.width / 2, y: playableRect.minY + playableRect.height * 1/6)
    addChild(label)
    
  }

}

class MoveScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // move(to:duration:)
    cat.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.move(to: CGPoint(x: playableRect.minX, y:playableRect.minY), duration:1.0),
        SKAction.move(to: cat.position, duration:1.0)
      ])
    ))
    
    // moveBy(x:y:duration:)
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.moveBy(x: 0, y: playableRect.height * 1/6, duration: 1.0),
        SKAction.moveBy(x: 0, y: -playableRect.height * 1/6, duration: 1.0)
      ])
    ))
    
    // moveTo(x:duration:) and moveTo(y:duration:)
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.group([
          SKAction.moveTo(x: playableRect.maxX, duration: 1.0),
          SKAction.moveTo(y: playableRect.minY, duration: 1.0),
        ]),
        SKAction.group([
          SKAction.moveTo(x: turtle.position.x, duration: 1.0),
          SKAction.moveTo(y: turtle.position.y, duration: 1.0),
        ])
      ])
    ))
    
    label.text = "Move Actions / Cross Fade"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.crossFade(withDuration: 1.0)
    let nextScene = RotateScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
  
}

class RotateScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // rotate(byAngle:duration:)
    cat.run(SKAction.repeatForever(
      SKAction.rotate(byAngle: π*2, duration: 1.0)
    ))
    
    // rotate(toAngle:duration:)
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.rotate(toAngle: π/2, duration: 1.0),
        SKAction.rotate(toAngle: π, duration: 1.0),
        SKAction.rotate(toAngle: -π/2, duration: 1.0),
        SKAction.rotate(toAngle: π, duration: 1.0),
      ])
    ))
    
    // rotate(toAngle:duration:shortestUnitArc:)
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.rotate(toAngle: π/2, duration: 1.0, shortestUnitArc:true),
        SKAction.rotate(toAngle: π, duration: 1.0, shortestUnitArc:true),
        SKAction.rotate(toAngle: -π/2, duration: 1.0, shortestUnitArc:true),
        SKAction.rotate(toAngle: π, duration: 1.0, shortestUnitArc:true),
      ])
    ))
    
    label.text = "Rotate Actions / Fade"
  }

  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.fade(withDuration: 1.0)
    let nextScene = ResizeScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }

}

class ResizeScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // resize(byWidth:height:duration:)
    cat.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.resize(byWidth: cat.size.width, height: -cat.size.height/2, duration: 1.0),
        SKAction.resize(byWidth: -cat.size.width, height: cat.size.height/2, duration: 1.0)
      ])
    ))
    
    // resize(toWidth:height:duration:)
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.resize(toWidth: 10, height: 200, duration: 1.0),
        SKAction.resize(toWidth: dog.size.width, height: dog.size.height, duration: 1.0)
      ])
    ))
    
    // resize(toWidth:duration:) and resize(toHeight:duration:)
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.group([
          SKAction.resize(toWidth: turtle.size.width*2, duration: 1.0),
          SKAction.resize(toHeight: turtle.size.height/2, duration: 1.0)
        ]),
        SKAction.group([
          SKAction.resize(toWidth: turtle.size.width, duration: 1.0),
          SKAction.resize(toHeight: turtle.size.height, duration: 1.0)
        ])
      ])
    ))
    
    label.text = "Resize Actions / Fade with Color"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.fade(with: SKColor.red, duration:1.0)
    let nextScene = ScaleScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
  
}

class ScaleScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // scale(by:duration:) and scale(to:duration:)
    cat.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.scale(by: 2.0, duration: 0.5),
        SKAction.scale(by: 2.0, duration: 0.5), // now effectively at 4x
        SKAction.scale(to: 1.0, duration: 1.0),
      ])
    ))
    
    // scaleX(by:y:duration:) and scaleX(to:y:duration:)
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.scaleX(by: 0.25, y:1.25, duration:0.5),
        SKAction.scaleX(by: 0.25, y:1.25, duration:0.5), // now effectively xScale 0.0625, yScale 1.565
        SKAction.scaleX(to: 1.0, y:1.0, duration:1.0),
      ])
    ))
    
    // scaleX(to:duration:) and scaleY(to:duration:)
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.group([
          SKAction.scaleX(to: 3.0, duration:1.0),
          SKAction.scaleY(to: 0.5, duration:1.0)
        ]),
        SKAction.group([
          SKAction.scaleX(to: 1.0, duration:1.0),
          SKAction.scaleY(to: 1.0, duration:1.0)
        ])
      ])
    ))
    
    label.text = "Scale Actions / Flip Horizontal"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.flipHorizontal(withDuration: 1.0)
    let nextScene = RepeatScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class RepeatScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // repeat(_:count:)
    cat.run(SKAction.repeat(
      SKAction.sequence([
        SKAction.moveBy(x: 0, y: playableRect.height * 1/6, duration: 0.2),
        SKAction.moveBy(x: 0, y: -playableRect.height * 1/6, duration: 0.2)
      ]), count:2
    ))
    
    dog.run(SKAction.repeat(
      SKAction.sequence([
        SKAction.moveBy(x: 0, y: playableRect.height * 1/6, duration: 0.2),
        SKAction.moveBy(x: 0, y: -playableRect.height * 1/6, duration: 0.2)
      ]), count:4
    ))
    
    // repeatForever(_:)
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.moveBy(x: 0, y: playableRect.height * 1/6, duration: 0.2),
        SKAction.moveBy(x: 0, y: -playableRect.height * 1/6, duration: 0.2)
      ])
    ))
    
    label.text = "Repeat Actions / Flip Vertical"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.flipVertical(withDuration: 1.0)
    let nextScene = FadeScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class FadeScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // fadeOut(withDuration:) and fadeIn(withDuration:)
    cat.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.fadeOut(withDuration: 1.0),
        SKAction.fadeIn(withDuration: 1.0)
      ])
    ))
    
    // fadeAlpha(by:duration:)
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.fadeAlpha(by: -0.75, duration: 1.0),
        SKAction.fadeAlpha(by: 0.75, duration: 1.0),
      ])
    ))
    
    // fadeAlpha(to:duration:)
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.fadeAlpha(to: 0.25, duration: 1.0),
        SKAction.fadeAlpha(to: 1.0, duration: 1.0),
      ])
    ))
    
    label.text = "Fade Actions / Reveal"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.reveal(with: .left, duration:1.0)
    let nextScene = TextureScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class TextureScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    let catTexture = SKTexture(imageNamed: "cat")
    let dogTexture = SKTexture(imageNamed: "dog")
    let turtleTexture = SKTexture(imageNamed: "turtle")
    
    // setTexture(_:)
    cat.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.setTexture(catTexture),
        SKAction.wait(forDuration: 0.25),
        SKAction.setTexture(dogTexture),
        SKAction.wait(forDuration: 0.25),
        SKAction.setTexture(turtleTexture),
        SKAction.wait(forDuration: 0.25)
      ])
    ))
    
    // animate(with:timePerFrame:)
    let textures = [catTexture, dogTexture, turtleTexture]
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.animate(with: textures, timePerFrame: 0.25)
      ])
    ))
    
    // animate(with:timePerFrame:resize:restore:)
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.animate(with: textures, timePerFrame: 0.25, resize: true, restore: true)
      ])
    ))
    
    label.text = "Texture Actions / Move In"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.moveIn(with: .left, duration: 1.0)
    let nextScene = SoundRemoveScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class SoundRemoveScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // removeFromParent()
    cat.run(SKAction.sequence([
      SKAction.wait(forDuration: 1.0),
      SKAction.removeFromParent()
    ]))
  
    // playSoundFileNamed(_:waitForCompletion:)
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: true),
        SKAction.moveBy(x: 0, y: playableRect.height * 1/6, duration: 1.0),
        SKAction.moveBy(x: 0, y: -playableRect.height * 1/6, duration: 1.0),
        SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: true),
        SKAction.rotate(byAngle: π*2, duration: 1.0)
      ])
    ))
    
    // removeFromParent()
    turtle.run(SKAction.sequence([
      SKAction.wait(forDuration: 1.0),
      SKAction.removeFromParent()
    ]))
    
    label.text = "Sound and Remove Actions / Push"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.push(with: .left, duration: 1.0)
    let nextScene = ColorizeScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class ColorizeScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    let dogTexture = SKTexture(imageNamed: "dog")
    cat.texture = dogTexture
    turtle.texture = dogTexture
    
    // colorize(with:colorBlendFactor:duration:) and colorize(withColorBlendFactor:duration:)
    cat.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.colorize(with: SKColor.red, colorBlendFactor: 1.0, duration: 1.0),
        SKAction.colorize(withColorBlendFactor: 0.0, duration: 1.0)
      ])
    ))
    
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.colorize(with: SKColor.red, colorBlendFactor: 0.25, duration: 1.0),
        SKAction.colorize(withColorBlendFactor: 0.0, duration: 1.0)
      ])
    ))
    
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.colorize(with: SKColor.red, colorBlendFactor: 1.0, duration: 1.0),
        SKAction.colorize(withColorBlendFactor: 0.0, duration: 1.0),
        SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 1.0),
        SKAction.colorize(withColorBlendFactor: 0.0, duration: 1.0),
        SKAction.colorize(with: SKColor.blue, colorBlendFactor: 1.0, duration: 1.0),
        SKAction.colorize(withColorBlendFactor: 0.0, duration: 1.0),
      ])
    ))
    
    label.text = "Colorize Actions / Doors Open"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
    let nextScene = FollowScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class FollowScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // follow(_:duration:)
    cat.position = CGPoint.zero
    let screenBorders = CGPath(rect: playableRect, transform: nil)
    cat.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.follow(screenBorders, duration:10.0)
      ])
    ))
    
    // follow(_:speed:)
    let stepAmt:CGFloat = 20
    let steps:CGFloat = 5
    let path = CGMutablePath()
    path.move(to: CGPoint(x: playableRect.minX, y: playableRect.minY))
    for i in stride(from: 0, to: steps, by: 1.0) {
      path.addLine(to: CGPoint(x: i*stepAmt, y: (i+1)*stepAmt))
      path.addLine(to: CGPoint(x: (i+1)*stepAmt, y: (i+1)*stepAmt))
    }
    for i in stride(from: 0, to: steps, by: 1.0) {
      path.addLine(to: CGPoint(x: (steps-i)*stepAmt, y: (steps-i-1)*stepAmt))
      path.addLine(to: CGPoint(x: (steps-i-1)*stepAmt, y: (steps-i-1)*stepAmt))
    }
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.follow(path, speed: 50.0)
      ])
    ))
    
    // follow(_:asOffset:orientToPath:duration:)
    let circle = CGPath(roundedRect: CGRect(x: playableRect.minX, y: playableRect.minY, width: 400, height: 400), cornerWidth: 200, cornerHeight: 200, transform: nil)
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.follow(circle, asOffset: false, orientToPath: false, duration: 5.0)
      ])
    ))
    
    label.text = "Follow Actions / Doors Close"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
    let nextScene = SpeedScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class SpeedScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // speed(to:duration:)
    cat.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.group([
          SKAction.speed(to: 5.0, duration:1.0),
          SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 1.0),
        ]),
        SKAction.group([
          SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 1.0),
        ]),
        SKAction.group([
          SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 1.0),
        ]),
        SKAction.group([
        SKAction.speed(to: 1.0, duration:1.0),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 1.0),
        ]),
      ])
    ))
    
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 0.25),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 0.25),
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 0.25),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 0.25),
        SKAction.speed(to: 0.5, duration:0.1),
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 0.25),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 0.25),
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 0.25),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 0.25),
        SKAction.speed(to: 1.0, duration:1.0),
      ])
    ))
    
    // speedBy(by:duration:)
    // TODO: BUG??? Getting unexpected behavior on this...
    
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 0.25),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 0.25),
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 0.25),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 0.25),
        SKAction.speed(by: -0.5, duration:0.1),
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 0.25),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 0.25),
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 0.25),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 0.25),
        SKAction.speed(by: 0.5, duration:1.0),
      ])
    ))
    
    label.text = "Speed Actions / Doorway"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.doorway(withDuration: 1.0)
    let nextScene = WaitScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class WaitScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // wait(forDuration:)
    cat.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 1.0),
        SKAction.wait(forDuration: 1.0),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 1.0),
      ])
    ))
    
    // wait(forDuration:withRange:)
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 1.0),
        SKAction.wait(forDuration: 1.0, withRange:1.0),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 1.0),
      ])
    ))
    
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 1.0),
        SKAction.wait(forDuration: 2.0, withRange:2.0),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 1.0),
      ])
    ))
    
    label.text = "Wait Actions / CIFilter"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    
    let filter = CIFilter(name: "CIDissolveTransition")!
    filter.setDefaults()
    
    let transition = SKTransition(ciFilter: filter, duration: 1.0)
    let nextScene = BlockScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class BlockScene : GameScene {

  func rotateCat() {
    cat.run(SKAction.rotate(byAngle: π*2, duration:1.0))
  }

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // run(_:)
    cat.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.run() { [weak self] in
          self?.rotateCat()
        },
        SKAction.wait(forDuration: 2.0)
      ])
    ))
    
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.run() { [weak self] in
          self?.dog.run(SKAction.rotate(byAngle: π*2, duration:1.0))
        },
        SKAction.wait(forDuration: 2.0)
      ])
    ))
    
    // run(_:queue:)
    let queue = DispatchQueue(label: "com.razeware.actionscatalog.bgqueue")
    var workDone = true
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.run({ [weak self] in
          guard let strongSelf = self else { return }
          if (workDone) {
            workDone = false
            strongSelf.turtle.run(SKAction.rotate(byAngle: π*2, duration:1.0))
            strongSelf.turtle.run(SKAction.run({
              sleep(1)
              workDone = true
            }, queue: queue))
          }
        }, queue: queue),
        SKAction.wait(forDuration: 1.0)
      ])
    ))
    
    label.text = "Block Actions"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.crossFade(withDuration: 1.0)
    let nextScene = ChildActionsScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class ChildActionsScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    cat.removeFromParent()
    cat.position = CGPoint(x: size.width * -1/3, y: 0)
    cat.name = "cat"
    dog.addChild(cat)
    
    turtle.removeFromParent()
    turtle.position = CGPoint(x: size.width * 1/3, y: 0)
    turtle.name = "turtle"
    dog.addChild(turtle)
    
    // children affected by action
    dog.run(SKAction.repeatForever(
      SKAction.rotate(byAngle: π*2, duration: 3.0)
    ))
    
    // run(_:onChildWithName:)
    dog.run(SKAction.run(SKAction.repeatForever(
      SKAction.rotate(byAngle: π*2, duration: 3.0)
    ), onChildWithName: "cat"))
    
    dog.run(SKAction.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.moveBy(x: -200, y:0, duration:1.0),
        SKAction.moveBy(x: 200, y:0, duration:1.0),
      ])
    ), onChildWithName: "turtle"))
    
    label.text = "Child Actions"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.crossFade(withDuration: 1.0)
    let nextScene = CustomActionScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class CustomActionScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // "Blink" action
    let blinkTimes = 6.0
    let duration = 2.0
    cat.run(SKAction.repeatForever(
      SKAction.customAction(withDuration: duration) { node, elapsedTime in
        let slice = duration / blinkTimes
        let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
        node.isHidden = remainder > slice / 2
      }
    ))
    
    // "Jump" action
    let dogStart = dog.position
    let jumpHeight = 100.0
    let dogDuration = 2.0
    dog.run(SKAction.repeatForever(
      SKAction.customAction(withDuration: duration) { node, elapsedTime in
        let fraction = Double(elapsedTime) / dogDuration
        let yOff = jumpHeight * 4 * fraction * (1 - fraction)
        node.position = CGPoint(x: node.position.x, y: dogStart.y + CGFloat(yOff))
      }
    ))
    
    // "Sin wave"
    let turtleStart = turtle.position
    let amplitude = 25.0
    let turtleDuration = 1.0
    turtle.run(SKAction.repeatForever(
      SKAction.customAction(withDuration: duration) { node, elapsedTime in
        let fraction = Double(elapsedTime) / turtleDuration
        let yOff = sin(Double.pi * 2 * fraction) * amplitude
        node.position = CGPoint(x: node.position.x, y: turtleStart.y + CGFloat(yOff))
      }
    ))
    
    label.text = "Custom Actions"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.crossFade(withDuration: 1.0)
    let nextScene = TimingScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class TimingScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // SKActionTimingMode.easeIn
    let catMoveUp = SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 1.0)
    catMoveUp.timingMode = .easeIn
    let catMoveDown = catMoveUp.reversed()
    cat.run(SKAction.repeatForever(
      SKAction.sequence([catMoveUp, catMoveDown])
    ))
    
    // SKActionTimingMode.easeOut
    let dogMoveUp = SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 1.0)
    dogMoveUp.timingMode = .easeOut
    let dogMoveDown = catMoveUp.reversed()
    dog.run(SKAction.repeatForever(
      SKAction.sequence([dogMoveUp, dogMoveDown])
    ))
    
    // SKActionTimingMode.easeInEaseOut
    let turtleMoveUp = SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 1.0)
    turtleMoveUp.timingMode = .easeInEaseOut
    let turtleMoveDown = catMoveUp.reversed()
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([turtleMoveUp, turtleMoveDown])
    ))
    
    label.text = "Timing Actions"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.crossFade(withDuration: 1.0)
    let nextScene = HideScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

class HideScene : GameScene {

  override func didMove(to view: SKView) {
  
    super.didMove(to: view)
    
    // hide() and unhide()
    cat.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.hide(),
        SKAction.wait(forDuration: 1.0),
        SKAction.unhide(),
        SKAction.wait(forDuration: 1.0),
      ])
    ))
    
    dog.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.hide(),
        SKAction.wait(forDuration: 0.5),
        SKAction.unhide(),
        SKAction.wait(forDuration: 0.5),
      ])
    ))
    
    turtle.run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.hide(),
        SKAction.wait(forDuration: 0.1),
        SKAction.unhide(),
        SKAction.wait(forDuration: 0.1),
      ])
    ))
    
    label.text = "Hide Actions"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    let transition = SKTransition.crossFade(withDuration: 1.0)
    let nextScene = MoveScene(size: size)
    nextScene.scaleMode = scaleMode
    view?.presentScene(nextScene, transition: transition)
  }
}

